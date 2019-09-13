#include <iostream>
#include <string>
#include <sstream>

#include <getopt.h>

#include "binaryblob.h"
#include "debug.h"

#define STACKSIZE 1024
int STACKOFFSET=0;


class EightThirtyTwoMemory
{
	public:
	EightThirtyTwoMemory(int ramsize) : uartbusyctr(0), ram(0), ramsize(ramsize), uartin(0)
	{
		ram=new unsigned char[ramsize];
	}
	virtual ~EightThirtyTwoMemory()
	{
		if(ram)
			delete[] ram;
	}
	virtual void SetUARTIn(const char *c)
	{
		uartin=c;
	}
	virtual int ReadB(unsigned int addr)
	{
	}
	virtual int Read(unsigned int addr)
	{
		switch(addr)
		{
			case 0xffffffc4:
				Debug[COMMENT] << std::endl << "Reading from SPI_CS" << std::endl;
				break;
			case 0xffffffc8:
				Debug[COMMENT] << std::endl << "Reading from SPI" << std::endl;
				break;
			case 0xffffffcc:
				Debug[COMMENT] << std::endl << "Reading from SPI_PUMP" << std::endl;
				break;
			case 0xda8000:
			case 0xffffff84:
			case 0xffffffc0:
				Debug[COMMENT] << std::endl << "Reading from UART" << std::endl;
				if(uartbusyctr)
				{
					--uartbusyctr;
					return(0);
				}
				else
				{
					int result=0x100;
					uartbusyctr=1;	// Make the UART pretend to be busy for the next n cycles
					if(uartin)
						result=0x300 | (unsigned char)*uartin++;	// Received byte ready...
					else
					{
						if(std::cin.readsome(inbuf,1))
							result=0x300 | (inbuf[0]&0xff);
					}

					if(result==0x300)	// End of string?
						uartin=0;

					return(result);
				}
				break;
			default:
				Debug[TRACE] << std::endl << "Reading from RAM" << addr << std::endl;
//				if(addr<ramsize)
				int r=(*this)[addr]<<24;
				r|=(*this)[addr+1]<<16;
				r|=(*this)[addr+2]<<8;
				r|=(*this)[addr+3];
				return(r);
//					return(ram[(addr&(ramsize-1))/4]);
		}
		return(0);
	}
	virtual void Write(unsigned int addr,int v)
	{
		switch(addr)
		{
			case 0xda8000:
				v>>=16;
			case 0xffffff84:
			case 0xffffffc0:
				if(char(v))
				{
					Debug[COMMENT] << std::endl << "Writing " << char(v) << " to UART" << std::endl;
					std::cout << char(v);
				}
				else
				{
					Debug[COMMENT] << std::endl << "Writing (nul) to UART" << std::endl;
					std::cout << "(nul)";
				}
				break;

			case 0xffffff88:
				Debug[COMMENT] << std::endl << "Setting UART divisor to " << v << std::endl;
				break;

			case 0xffffff8C:
				Debug[COMMENT] << std::endl << "Writing to overlay register: " << v << std::endl;
				break;

			case 0xffffff90:
				Debug[COMMENT] << std::endl << "Writing " << v << " to HEX display" << std::endl;
				break;

			case 0xffffffc4:
				Debug[COMMENT] << std::endl << "Setting spi_cs line " << (v&1 ? "low" : "high" ) << std::endl;
				break;

			case 0xffffffc8:
				Debug[COMMENT] << std::endl << "Writing " << v << " to SPI" << std::endl;
				break;

			case 0xffffffcc:
				Debug[COMMENT] << std::endl << "Writing " << v << " to SPI_pump" << std::endl;
				break;

			case 0xfffffffc:
				Debug[COMMENT] << std::endl << "Breadcrumb " << std::endl;
				break;

			default:
				(*this)[addr]=(v>>24)&255;
				(*this)[addr+1]=(v>>16)&255;
				(*this)[addr+2]=(v>>8)&255;
				(*this)[addr+3]=v&255;

//				if(addr<ramsize)
//				{
//					Debug[TRACE] << std::endl << "Writing " << v << " to RAM " << addr << std::endl;
//					ram[(addr&(ramsize-1))/4]=v;
//				}
		}
	}
	virtual unsigned char &operator[](const int idx)
	{
		return(ram[idx]);
	}
	virtual int GetRAMSize()
	{
		return(ramsize);
	}
	protected:
	int uartbusyctr;
	unsigned char *ram;
	int ramsize;
	const char *uartin;
	char inbuf[4];
};


// EightThirtyTwoProgram overlays the program loaded from disk onto a fixed-size memory block.
// Accesses within the program are sent directly to the binary blob.
// Accesses beyond the program are passed to the EightThirtyTwoMemory superclass.
// FIXME - need to support byte accesses to EightThirtyTwoMemory.

class EightThirtyTwoProgram : public BinaryBlob, public EightThirtyTwoMemory
{
	public:
	EightThirtyTwoProgram(const char *filename, int ramsize=8*1024*1024) : BinaryBlob(filename), EightThirtyTwoMemory(ramsize), base(0)
	{
	}
	~EightThirtyTwoProgram()
	{
	}
	virtual int Read(unsigned int addr)
	{
		if(((addr-base)>=0) && ((addr-base)<(size-3)))
		{
			int r=(*this)[addr]<<24;
			r|=(*this)[addr+1]<<16;
			r|=(*this)[addr+2]<<8;
			r|=(*this)[addr+3];
			return(r);
		}
		return(EightThirtyTwoMemory::Read(addr));
	}
	virtual void Write(unsigned int addr,int v)
	{
		if(((addr-base)>=0) && ((addr-base)<(size-3)))
		{
			(*this)[addr]=(v>>24)&255;
			(*this)[addr+1]=(v>>16)&255;
			(*this)[addr+2]=(v>>8)&255;
			(*this)[addr+3]=v&255;
		}
		else
			EightThirtyTwoMemory::Write(addr,v);
	}
	void SetBase(int base)
	{
		this->base=base;
	}
	unsigned char &operator[](const int idx)
	{
		if(idx<size)
			return(BinaryBlob::operator[](idx));
		else
//			throw "Byte accesses to general RAM not yet supported";
			return(EightThirtyTwoMemory::operator[](idx));
	}
	protected:
	int base;
};





class EightThirtyTwoSim 
{
	public:
	EightThirtyTwoSim() : initpc(0), steps(-1)
	{		
	}

	~EightThirtyTwoSim()
	{
	}

	int ParseOptions(int argc,char *argv[])
	{
		static struct option long_options[] =
		{
			{"help",no_argument,NULL,'h'},
			{"steps",required_argument,NULL,'s'},
			{"offset",required_argument,NULL,'o'},
			{"report",required_argument,NULL,'r'},
			{0, 0, 0, 0}
		};
		bool offset=false;
		int stackbit=30;
		bool stackboot=false;

		while(1)
		{
			int c;
			c = getopt_long(argc,argv,"hs:r:o:bm",long_options,NULL);
			if(c==-1)
				break;
			switch (c)
			{
				case 'h':
					printf("Usage: %s [options] <UART input text>\n",argv[0]);
					printf("    -h --help\t  display this message\n");
					printf("    -s --steps\t  Simulate a specific number of steps (default: indefinite)\n");
					printf("    -r --report\t  set reporting level - 0 for silent, 4 for verbose\n");
					printf("    -o --offsetstack\t  specify base address for stack RAM. Zero by default,\n");
					printf("\t\t  specified as a bit number, so 30=0x40000000, etc.\n");
					break;
				case 'o':
					offset=true;
					stackbit=atoi(optarg);
					break;
				case 's':
					steps=atoi(optarg);
					break;
				case 'r':
					Debug.SetLevel(DebugLevel(atoi(optarg)));
					break;
			}
		}

		return(optind);
	}

	

	int GetOpcode(EightThirtyTwoMemory &prg, int pc)
	{
		int t=prg.Read(pc&~3);
		int opcode=t>>((3-(pc&3))<<3);
		return(opcode&0xff);
	}


	void Run(EightThirtyTwoProgram &prg)
	{
		Debug[WARN] << "Starting simulation" << std::endl;
		Debug[ERROR] << std::hex << std::endl;
		for(int i=0;i<7;++i)
			regfile[i]=0;
		regfile[7]=initpc;
                regfile[6]=prg.GetRAMSize();
		zero=0; carry=0;
		cond=1;

		bool run=true;
		bool immediate_continuation=false;

		while(run)
		{
			int nextpc;
			int opcode;
			int operand;
			int operim;
			int t;
			long long t2;

			std::stringstream mnem;
			mnem << std::hex;

			opcode=GetOpcode(prg,regfile[7]);
			operand=opcode&0x7;
			operim=opcode&0x3f;
			opcode&=0xf8;

			nextpc=regfile[7]+1;
			regfile[7]=nextpc;			

			if(cond) // is execution enabled?
			{
				if((opcode&0xc0)==0xc0)
				{
					if(immediate_continuation)
					{
						temp<<=6;
						temp|=operim;
						mnem<<("li (cont) ");
						mnem << operim;
					}
					else
					{
						temp=operim;
						if(operim&0x20)
							temp|=0xffffffc0;
						mnem<<("li ");
						mnem<< operim;
						immediate_continuation=true;
					}
				}
				else
				{
					immediate_continuation=false;
					switch(opcode)
					{
						case 0x00: // cond
							if(!operand)
								steps=1;
							t=((zero&carry)<<3)|((!zero&carry)<<2)|((zero&!carry)<<1)|(!zero&!carry);
							operand|=(operand&2)<<2;
							cond=(operand&t)>0;
							mnem << ("cond ") << operand << (", ") << t;
							break;

						case 0x88: // mt
							temp=regfile[operand];
							mnem << ("mt ") << operand;
							break;

						case 0x08: // mr
							regfile[operand]=temp;
							if(operand==7)
								cond=1; // cancel cond on write to r7
							mnem << ("mr ") << operand;
							break;

						case 0x80: // exg
							t=regfile[operand];
							regfile[operand]=temp;
							temp=t;
							if(operand==7)
								cond=1; // cancel cond on write to r7
							mnem << ("exg ") << operand;
							break;

#if 0
						case 0xb0: // ldx
							temp=prg.Read((regfile[operand]+regfile[5])&0xfffffffc);
							mnem << ("ldx ") << operand;
							break;
#endif

						case 0x20: // st
							prg.Write(regfile[operand],temp); // &0xfffffffc,temp);
							mnem << ("st ") << operand;
							break;

						case 0xa0: // ld
							if(operand==7)	//
							{ 
								temp=prg.Read(temp);
								mnem << ("ldt ");
							}
							else
							{
								temp=prg.Read(regfile[operand]); // &0xfffffffc);
								mnem << ("ld ") << operand;
							}
							break;

#if 0
						case 0x30: // stx
							prg.Write((regfile[operand]+regfile[5])&0xfffffffc,temp);
							mnem << ("stx ") << operand;
							break;
#endif
						case 0x30: // stmpdec
							temp-=4;
							prg.Write(temp,regfile[operand]);
							mnem << ("stmpdec ") << operand;
							break;

						case 0x90: // add
							t2=regfile[operand]+temp;
							carry=(t2>>32)&1;
							zero=(t2&0xffffffff)==0;
							if(operand==7)
							{
								cond=1; // cancel cond on write to r7
								temp=regfile[operand];	// For r7, previous value goes to temp
							}
							regfile[operand]=t2;
							mnem << ("add ") << operand;
							break;

						case 0x18: // cmp
							t2=regfile[operand]-temp;
							carry=(t2>>32)&1;
							zero=(t2&0xffffffff)==0;
							mnem << ("cmp ") << operand;
							break;

						case 0xa8: // ldinc
							temp=prg.Read(regfile[operand]); // &0xfffffffc);
							regfile[operand]+=4;
							mnem << ("ldinc ") << operand;
							break;

						case 0x10: // sub
							t2=regfile[operand]-temp;
							carry=(t2>>32)&1;
							regfile[operand]=t2;
							zero=(t2&0xffffffff)==0;
							if(operand==7)
								cond=1; // cancel cond on write to r7
							mnem << ("sub ") << operand;
							break;

						case 0x28: // stdec
							if(operand==7)	//
							{ 
								--temp;
								mnem << ("dect ");
							}
							else
							{
								regfile[operand]-=4;
								prg.Write(regfile[operand],temp); //&0xfffffffc,temp);
								mnem << ("stdec ") << operand;
							}
							break;

						case 0x40: // and
							regfile[operand]&=temp;
							carry=0;
							zero=regfile[operand]==0;
							mnem << ("and ") << operand;
							break;

						case 0x48: // or
							regfile[operand]|=temp;
							carry=0;
							zero=regfile[operand]==0;
							mnem << ("or ") << operand;
							break;

						case 0x50: // xor
							regfile[operand]^=temp;
							carry=0;
							zero=regfile[operand]==0;
							mnem << ("xor ") << operand;
							break;

						case 0x98: // addt;
							t=regfile[operand];
							t2=regfile[operand]+temp;
							carry=(t2>>32)&1;
							zero=(t2&0xffffffff)==0;
							if(operand==7)
								cond=1; // cancel cond on write to r7
							temp=t2; // result goes to temp.

							mnem << ("addt ") << operand;
							break;

						case 0x58: // shl
							t2=regfile[operand]<<(temp-1);
							carry=t2>>32;
							regfile[operand]<<=temp;
							zero=regfile[operand]==0;
							mnem << ("shl ") << operand;
							break;

						case 0x60: // asr
							carry=regfile[operand]>>(temp-1);
							carry&=1;
							t=regfile[operand];
							t>>=temp;
							regfile[operand]=t;
							zero=regfile[operand]==0;
							mnem << ("asr ") << operand;
							break;

						case 0x68: // lsr
							carry=regfile[operand]>>(temp-1);
							carry&=1;
							regfile[operand]>>=temp;
							zero=regfile[operand]==0;
							mnem << ("lsr ") << operand;
							break;

						case 0x70: // ror
							t=regfile[operand]<<(32-temp);
							regfile[operand]=(regfile[operand]>>temp)|t;
                                                        mnem << ("ror ") << operand;
//							throw "ror not yet implemented\n";
							break;

//						case 0x78: // rorc
//							throw "rorc not yet implemented\n";
//							break;

						case 0x78: // ltmpinc
							regfile[operand]=prg.Read(temp);//&0xfffffffc);
							temp+=4;
							mnem << ("ldinc ") << operand;
							break;


						case 0x38: // stbinc
							if(operand==7)	//
							{ 
								++temp;
								mnem << ("inct ");
							}
							else
							{
								prg[regfile[operand]]=temp&0xff;
								regfile[operand]++;
								mnem << ("stbinc ") << operand;
							}
//							putchar(temp&0xff);
							break;

						case 0xb8: // ldbinc
							temp=prg[regfile[operand]];
							regfile[operand]++;
							if(!temp)
								zero=1;
							carry=0;
							mnem << ("ldbinc ") << operand;
							break;

					}
				}
			}
			else // execution disabled by cond
			{
				mnem << ("(");
				if(opcode==0x00)
				{
					// FIXME - match against zero and carry, set cond flag accordingly.
					t=((zero&carry)<<3)|((!zero&carry)<<2)|((zero&!carry)<<1)|(!zero&!carry);
					operand|=(operand&2)<<2;
					cond=(operand&t)>0;
					mnem << ("cond ") << operand;
					break;
				}
				else if(operand==7)
				{
					switch(opcode)
					{
						case 0x08: // mr
						case 0x80: // exg
						case 0x90: // add
						case 0x10: // sub
						case 0x98: // addt;
							cond=1;
					}
				}
				mnem << (")");
			}
			if(steps>0)
				run=(--steps)!=0;

			Debug[TRACE] << "r7: " << regfile[7] << "\tOp: " << opcode << ", " << mnem.str() << "\n\t\t";
			DumpRegs();
			Debug[TRACE] << std::endl;
		}
	}
	void DumpRegs()
	{
		Debug[TRACE] << "Temp: " << temp << ", ";
		for(int i=0;i<7;++i)
		{
			Debug[TRACE] << "r" << i << ": " << regfile[i] << ", ";
		}
		Debug[TRACE] << "Z: " << zero << ", C: " << carry << ", Cond: " << cond;
	}
	protected:
	unsigned int regfile[8];
	int cond;
	int temp;
	int zero;
	int carry;
	int initpc;
	int steps;
};


int main(int argc, char **argv)
{
	try
	{
		Debug.SetLevel(WARN);
		if(argc>1)
		{
			int i;
			char *uartin=0;
			EightThirtyTwoSim sim;
			i=sim.ParseOptions(argc,argv);
			if(i<argc)
			{
				EightThirtyTwoProgram prg(argv[i++]);
				if(i<argc)
				{
					Debug[TRACE] << "Setting uartin to " << argv[i] << std::endl;
					prg.SetUARTIn(argv[i++]);
				}
				else
				{
					Debug[TRACE] << "All arguments used: " << i << ", " << argc << std::endl;
				}
				sim.Run(prg);
				std::cout << std::endl;
			}
		}
	}
	catch(const char *err)
	{
		std::cerr << "Error: " << err << std::endl;
	}
	return(0);
}

