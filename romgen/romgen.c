// romgen.c
//
// Program to turn a binary file into a VHDL lookup table.
//   by Adam Pierce
//   29-Feb-2008
//
// Modified by Alastair M. Robinson
//
// This software is free to use by anyone for any purpose.
//
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h> 
#include <getopt.h>

typedef unsigned char BYTE;

struct RomGenOptions
{
	int offset;
	int limit;
	int byteswap;
	int	word;
	int wordsize;
};

int ParseOptions(int argc,char **argv,struct RomGenOptions *opts)
{
	static struct option long_options[] =
	{
		{"help",no_argument,NULL,'h'},
		{"offset",required_argument,NULL,'o'},
		{"limit",required_argument,NULL,'l'},
		{"word",no_argument,NULL,'w'},
		{"byteswap",no_argument,NULL,'b'},
		{"wordsize",required_argument,NULL,'s'},
		{0, 0, 0, 0}
	};

	while(1)
	{
		int c;
		c = getopt_long(argc,argv,"ho:l:wbs:",long_options,NULL);
		if(c==-1)
			break;
		switch (c)
		{
			case 'h':
				printf("Usage: %s [options] <filename>\n",argv[0]);
				printf("    -h --help\t  display this message\n");
				printf("    -w --word\t  output as word-oriented rather than byte-oriented.\n");
				printf("    -o --offset\t  skip a number of bytes before outputting ROM data.\n");
				printf("    -l --limit\t  stop after a specified number of bytes of ROM data.\n");
				printf("    -b --byteswap\t  reverse the byte order of the ROM data.\n");
				printf("    -s --wordsize\t  number of bytes in each word.\n");
				break;
			case 'o':
				opts->offset=atoi(optarg);
				break;
			case 'l':
				opts->limit=atoi(optarg);
				break;
			case 'b':
				opts->byteswap=1;
				break;
			case 'w':
				opts->word=1;
				break;
			case 's':
				opts->wordsize=atoi(optarg);
				break;
		}
	}
	return(optind);
}

int main(int argc, char **argv)
{
	BYTE    opcode[4];
	FILE     *fd;
	int     addr = 0;
	int i;
	struct RomGenOptions opts;
	ssize_t s;
	char *preamble,*bytefmt,*delimiter,*suffix;

	opts.limit=0x7fffffff;
	opts.offset=0;
	opts.byteswap=0;
	opts.word=0;
	opts.wordsize=4;

	i=ParseOptions(argc,argv,&opts);

	// Check the user has given us an input file.
	if(i>=argc)
	return 1;

	if(opts.wordsize!=2 && opts.wordsize!=4)
		perror("Word size must be either 2 or 4 bytes");

	// Open the input file.
	fd = fopen(argv[i],"rb");
	if(!fd)
	{
		perror("File Open");
		return 2;
	}

	if(opts.word) {
		preamble="%6d => x\"";
		bytefmt="%02x";
		delimiter="";
		suffix="\",\n";
	} else {
		preamble="%6d => (";
		bytefmt="x\"%02x\"";
		delimiter=",";
		suffix="),\n";
	}

	while(addr<(opts.limit/opts.wordsize))
	{
		int l1=opts.byteswap ? opts.wordsize-1 : 0;
		int l2=opts.byteswap ? 0 : opts.wordsize-1;
		int step=opts.byteswap ? -1 : 1;
		int i;

		// Read 32 bits.
		if(opts.offset)
		{
			while(opts.offset>0)
			{
				s = fread(opcode, 1, opts.wordsize, fd);
				opts.offset-=opts.wordsize;
			}
		}
		for(i=0;i<opts.wordsize;++i)
			opcode[i]=0;
		s = fread(opcode, 1, opts.wordsize, fd);
		if(s==0)
		{
			if(feof(fd))
				break; // End of file
			else
			{
				perror("File read");
				return 3;
			}
		}

		// Output to STDOUT.

		printf(preamble,addr);
		for(i=l1;i!=l2+step;i+=step) {
			printf(bytefmt,opcode[i]);
			if(i!=l2)
				printf("%s",delimiter);
		}
		printf("%s",suffix);
		++addr;
	}

	fclose(fd);
	return 0;
}

