#include <stdio.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <string.h>

#include "832ocd.h"
#include "832ocd_connection.h"


struct ocd_connection *ocd_connection_new()
{
	struct ocd_connection *result=0;
	result=(struct ocd_connection *)malloc(sizeof(struct ocd_connection *));
	if(result)
	{
		result->connected=0;
		result->sock=socket(AF_INET, SOCK_STREAM, 0);
		if(result->sock < 0)
		{
			fprintf(stderr,"Failed to create socket\n");
			free(result);
			return(0);
		}
	}
	return(result);
}


void ocd_connection_delete(struct ocd_connection *con)
{
	if(con)
	{
		if(con->connected)
			close(con->sock);
		free(con);
	}
}


int ocd_connect(struct ocd_connection *con,const char *ip,int port)
{
	if(con)
	{
		if(con->connected)
			close(con->sock);
		con->connected=0;

	    memset(&con->serv_addr, '0', sizeof(con->serv_addr));
		con->serv_addr.sin_family = AF_INET;
		con->serv_addr.sin_port = htons(port);
      
		if(inet_pton(AF_INET, ip, &con->serv_addr.sin_addr)<=0) 
		{
			fprintf(stderr,"Invalid address / Address not supported \n");
			return(0);
		}

		if (connect(con->sock, (struct sockaddr *)&con->serv_addr, sizeof(con->serv_addr)) < 0)
		{
			fprintf(stderr,"Connection Failed \n");
			return(0);
		}
		return(1);
	}
	return(0);
}


int ocd_command(struct ocd_connection *con,enum dbg832_op op,int paramcount,int responsecount,int p1,int p2,int p3)
{
	int result=0;
	int l=4;

	if(!con)
		return(0);

	con->cmdbuffer[0]=op;
	con->cmdbuffer[1]=paramcount;
	con->cmdbuffer[2]=responsecount;
	con->cmdbuffer[3]=p1;
	switch(paramcount)
	{
		case 8:	/* Two 32-bit parameters */
			con->cmdbuffer[8]=(p3>>24);
			con->cmdbuffer[9]=(p3>>16)&255;
			con->cmdbuffer[10]=(p3>>8)&255;
			con->cmdbuffer[11]=(p3)&255;
			l+=4;
			/* Fall through */
		case 4: /* First 32-bit parameter */
			con->cmdbuffer[4]=(p2>>24);
			con->cmdbuffer[5]=(p2>>16)&255;
			con->cmdbuffer[6]=(p2>>8)&255;
			con->cmdbuffer[7]=(p2)&255;
			l+=4;
			break;
		default:
			break;
	}
    send(con->sock,con->cmdbuffer,l,0);
	while(responsecount--)
	{
		read(con->sock,con->cmdbuffer,1);
		result=(result<<8)|(con->cmdbuffer[0]&255);
	}
	return(result);
}


#if 0
int main(int argc, char const *argv[])
{
	int result;
    int valread;

	struct ocd_connection *con;

	con=ocd_connection_new();
	if(!con)
		return(0);

	if(ocd_connect(con,OCD_ADDR,OCD_PORT))
	{
		printf("Connected...\n");

	}

//	result=ocd_command(con,DBG832_READ,4,4,7,0x0000004,0);
	result=OCD_READ(con,4);
	printf("%08x\n",result);
//	result=ocd_command(con,DBG832_SINGLESTEP,0,0,7,0,0);
	result=OCD_SINGLESTEP(con);
	printf("%08x\n",result);
	result=OCD_READREG(con,7);
//	result=ocd_command(con,DBG832_READREG,0,4,7,0,0);
	printf("%08x\n",result);
//	result=command(sock,DBG832_RELEASE,0,0,0,0,0);
//	printf("%08x\n",result);
//	result=command(sock,DBG832_SINGLESTEP,0,0,7,0x12345678,0);
//	printf("%08x\n",result);
    return 0;
}
#endif

