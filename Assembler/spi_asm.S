#include "assembler.pp"

#define SPIBASE 0xFFFFFFD0

#define HW_SPI_CS 0x0	/* CS bits are write-only, but bit 15 reads as the SPI busy signal */
#define HW_SPI_DATA 0x04 /* Blocks on both reads and writes, making BUSY signal redundant. */

#define HW_SPI_B_SD 0
#define HW_SPI_B_FAST 8
#define HW_SPI_F_SD (1<<HW_SPI_B_SD)
#define HW_SPI_F_FAST (1<<HW_SPI_B_FAST)


#define cmd_reset 0x9540 // Use SPI mode
#define cmd_init 0xff41
#define cmd_read 0xff51
#define cmd_CMD8 0x8748
#define lba_CMD8 0x1AA
#define cmd_CMD16 0xFF50
#define cmd_CMD41 0x8769
#define lba_CMD41 0x40000000
#define cmd_CMD55 0xff77
#define cmd_CMD58 0xff7A


// ZPU GCC SPI routines take up 1516 bytes in total, for comparison.

SPI_Pump:	// Return longword in r0, HW_SPI_DATA must be in r5
	stdec	r6

	ld	r5
	mr	r0
	li	8
	shl	r0

	ld	r5
	or	r0
	li	8
	shl	r0

	ld	r5
	or	r0
	li	8
	shl	r0

	ld	r5
	or	r0

	ldinc	r6
	mr	r7	// 17 bytes  -  GCC assembled ZPU equivalent: 78 bytes


is_sdhc:
	.byte	0

SPI_Send:	// command in r0, lba in r1, expected response in r2, HW_SPI_DATA must be in r5
	stdec	r6

	mt	r0
	st	r5	// SPI(cmd&255); // Assume only low 8 bits are active.

	// FIXME - better to do this only for read / write commands
	li	IMW1(PCREL(is_sdhc-1))
	li	IMW0(PCREL(is_sdhc))
	addt	r7

	ldt
	cond	EQ
		li	9
		shl	r1	// Multiply LBA by 512 if we have a standard SD card.
		cond	EX	// 13 bytes
	

	li	IMW0(24)
	ror	r1	// Rotate left 8 bits

	li	IMW0(8)
	exg	r1
	st	r5	// LBA high bits
	exg	r1
	ror	r1
	exg	r1
	st	r5	// LBA 23 - 16
	exg	r1
	ror	r1
	st	r5	// LBA 15-8
	exg	r1
	ror	r1
	st	r5	// LBA low byte
	exg	r1

	ror	r0
	exg	r0
	st	r5	// CRC byte, if necessary.	//  34 bytes
	li	IMW2(40000)
	li	IMW1(40000)
	li	IMW0(40000)
	mr	r1
	li	IMW1(255)
	li	IMW0(255)
	mr	r0
.loop:
	st	r5
	ld	r5
	exg	r0
	cmp	r0
	cond	NEQ
		li	IMW0(PCREL(.done))
		mr	r7	// 49 bytes

	exg	r0
	li	1
	sub	r1
	cond	NEQ
		li	IMW0(PCREL(.loop))
		mr	r7

.done:
	ldinc	r6
	mr	r7	// 59 bytes  -  GCC compiled ZPU equivalent 128 bytes


SPI_Spin:	// GCC compiled ZPU equivalent, 26 bytes
	stdec	r6
	li	IMW1(200)
	li	IMW0(200)
	mr	r0
.spinloop:
	li	IMW0(-1)
	mr	r5
	add	r0
	cond	NEQ
	li	IMW0(PCREL(.spinloop))
	mr	r7

	ldinc	r6
	mr	r7	// 12 bytes

		// GCC ZPU equivalent: 120 bytes
SD_WaitInitV2:	// r0 is 1 on success, 0 on failure.  r5 must point to SPI_HW_DATA reg
	stdec	r6
	mt	r1
	stdec	r6
	mt	r2
	stdec	r6

	li	IMW0(PCREL(SPI_Spin))
	add	r7

	li	IMW3(20000)
	li	IMW1(20000)
	li	IMW0(20000)
	mr	r2	// 11
.initv2loop:
	li	1
	sub	r2
	cond	EQ
	  li	0
	  mr	r0
	  li	IMW1(PCREL(.initv2done-1))
	  li	IMW0(PCREL(.initv2done))
	  mr	r7	// Escape loop

	li	IMW2(cmd_CMD55)
	li	IMW1(cmd_CMD55)
	li	IMW0(cmd_CMD55)
	mr	r0
	li	0
	mr	r1
	li	IMW1(PCREL(SPI_Send-1))
	li	IMW0(PCREL(SPI_Send))
	add	r7
	li	1
	cmp	r0
	cond	NEQ	// If we didn't get a 1, loop
	  li	IMW0(PCREL(.initv2loop))
	  mr	r7	// 20  ->  31

	// CMD55 succeeded - try CMD41

	li	-1
	st	r5

	li	IMW2(cmd_CMD41)
	li	IMW1(cmd_CMD41)
	li	IMW0(cmd_CMD41)
	mr	r0

	li	IMW0(lba_CMD41>>28)
	mr	r1
	li	28
	shl	r1

	li	IMW1(PCREL(SPI_Send-1))
	li	IMW0(PCREL(SPI_Send))
	add	r7

	li	0
	cmp	r0
	li	-1
	cond	EQ	// 17 -> 48

	  st	r5
	  sub	r0
	  li	IMW0(PCREL(.initv2done))
	  mr	r7	// 52

	li	IMW1(PCREL(SPI_Spin-1))
	li	IMW0(PCREL(SPI_Spin))
	add	r7

	li	IMW0(PCREL(.initv2loop))
	mr	r7	// 57 bytes


.initv2done:
	ldinc	r6
	mr	r2
	ldinc	r6
	mr	r1
	ldinc	r6
	mr	r7	// 63 bytes


		// ZPU / gcc equivalent: 88 bytes
SD_WaitInit:	// Sends init command, returns 1 in r0 for success, 0 for failure.  r5 must contain SPI_HW_DATA reg.
	stdec	r6
	mt	r1
	stdec	r1
	mt	r2
	stdec	r2

	li	20
	mr	r2

	li	-1
	st	r5	// SPI(0xff)  - 9 bytes

.waitinitloop:
	li	-1
	add	r2
	cond	EQ	// Failed
	  li	0
	  mr	r0
	  li	IMW0(PCREL(.waitinitdone))
	  mr	r7

	li	IMW2(cmd_init)
	li	IMW1(cmd_init)
	li	IMW0(cmd_init)
	mr	r0
	li	0
	mr	r1
	li	IMW1(PCREL(SPI_Send-1))
	li	IMW0(PCREL(SPI_Send-1))
	add	r7	// 16 -> 25 bytes

	li	0
	cmp	r0
	cond	EQ
	  li	-1
	  st	r5
	  li	1
	  st	r0
	  li	IMW0(PCREL(.waitinitdone))
	  add	r7

	li	IMW1(PCREL(SPI_Spin-1))
	li	IMW0(PCREL(SPI_Spin))
	add	r7

	li	IMW0(PCREL(.waitinitloop))
	mr	r7	// 14 -> 39 bytes

.waitinitdone:
	ldinc	r6
	mr	r2
	ldinc	r6
	mr	r1
	ldinc	r6
	mr	r7	// 45 bytes


SD_Init:  // ZPU GCC equivalent: 219 bytes
	exg	r6
	stmpdec	r6
	stmpdec	r1
	stmpdec	r4
	stmpdec	r5
	mr	r6	// 6 bytes
	

	li	IMW1(SPIBASE+HW_SPI_CS)
	li	IMW0(SPIBASE+HW_SPI_CS)
	mr	r4
	ltmpinc	r5	// Quickest way to increment r5
	mr	r5	// SPI_DATA -> r5
	li	0
	st	r4	// SPI_CS(0)
	li	IMW1(PCREL(SPI_Spin-1))
	li	IMW0(PCREL(SPI_Spin))
	add	r7	// 10 -> 16 bytes

	li	1
	st	r4	// SPI_CS(1)

	li	8
	mr	r4
.spiinitloop1:
	li	0
	mr	r1
	li	IMW2(cmd_reset)
	li	IMW1(cmd_reset)
	li	IMW0(cmd_reset)
	mr	r0
	li	IMW1(PCREL(SPI_Send))
	li	IMW0(PCREL(SPI_Send))
	add	r7	// 13 -> 29 bytes

	li	1
	cmp	r0
	cond	EQ
	  li	IMW0(PCREL(.spiinit_resetok))
	  mr	r7

	sub	r4
	cond	EQ	// Bail out if the card doesn't respond.
	  li	IMW0(PCREL(.spiinitdone))
	  mr	r7	// 9 -> 38 bytes

.spiinit_resetok:
	li	1
	mr	r4	// Return code
	li	IMW1(PCREL(SD_IsSDHC))
	li	IMW0(PCREL(SD_IsSDHC))
	add	r7
	li	0
	cmp	r0
	cond	NEQ
	  li	IMW0(PCREL(.spiinitdone))
	  mr	r7

	li	1
	mr	r1
	li	IMW2(cmd_CMD16)
	li	IMW1(cmd_CMD16)
	li	IMW0(cmd_CMD16)
	mr	r0
	li	IMW1(PCREL(SPI_Send))
	li	IMW0(PCREL(SPI_Send))
	add	r7	// 19 -> 57 bytes

.spiinitdone:
	li	-1
	st	r5	// SPI(0xff)
	li	0
	stdec	r5	// CS(0)
	ldinc	r5	// Restore pointer
	li	-1
	st	r5	// SPI(0xff)

	mt	r4
	mr	r0
	mt	r6
	ltmpinc	r5
	ltmpinc	r4
	ltmpinc	r1
	ltmpinc	r6
	exg	r6
	mr	r7	// 16 bytes -> 73 bytes


SD_IsSDHC:

	mr	r7

#if 0


int is_sdhc()
{
	int i,r;

	spi_spin();

	r=cmd_CMD8();		// test for SDHC capability
	printf("cmd_CMD8 response: %d\n",r);
	if(r!=1)
	{
		wait_init();
		return(0);
	}

	r=SPI_PUMP();
	if((r&0xffff)!=0x01aa)
	{
		printf("CMD8_4 response: %d\n",r);
		wait_init();
		return(0);
	}

	SPI(0xff);

	// If we get this far we have a V2 card, which may or may not be SDHC...

	i=50;
	while(--i)
	{
		if(wait_initV2())
		{
			if((r=cmd_CMD58())==0)
			{
				printf("CMD58 %d\n  ",r);
				SPI(0xff);
				r=SPI_READ();
				printf("CMD58_2 %d\n  ",r);
				SPI(0xff);
				SPI(0xff);
				SPI(0xff);
				SPI(0xff);
				if(r&0x40)
					return(1);
				else
					return(0);
			}
			else
				printf("CMD58 %d\n  ",r);
		}
		if(i==2)
		{
			printf("SDHC Initialization error!\n");
			return(0);
		}
	}
	return(0);
}


int sd_write_sector(unsigned long lba,unsigned char *buf) // FIXME - Stub
{
	return(0);
}


extern void spi_readsector(long *buf);

int spi_checksum;

int sd_read_sector(unsigned long lba,unsigned char *buf)
{
	int result=0;
	int i;
	int r;
//	printf("sd_read_sector %d, %d\n",lba,buf);
	SPI(0xff);
	SPI_CS(1|(1<<HW_SPI_FAST));
	SPI(0xff);

	r=cmd_read(lba);
	if(r!=0)
	{
		printf("Read command failed at %d (%d)\n",lba,r);
		return(result);
	}

	i=1500000;
	while(--i)
	{
		int v;
		SPI(0xff);
//		SPI_WAIT();
		v=SPI_READ();
		if(v==0xfe)
		{
//			puts("Reading sector data\n");
//			spi_readsector((long *)buf);
			int j;
//			SPI(0xff);
			spi_checksum=0;
			for(j=0;j<128;++j)
			{
				int t,v;

				t=SPI_PUMP();
				*(int *)buf=t;
//				printf("%d: %d\n",buf,t);
				buf+=4;
				spi_checksum+=t;
			}

			i=1; // break out of the loop
			result=1;
		}
	}
	SPI(0xff);
	SPI_CS(0);
	return(result);
}


#endif

