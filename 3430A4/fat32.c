/*--------------------------------------------------------------------
  Student Name: <Michael Bathie>
  Student ID: <7835010>
  Section: <A01>
--------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include "fat32.h"
#include "FSInfo.h"
#include "fat32Dir.h"


/*
	returns the first sector number of any cluster
*/
static uint32_t first_sector(fat32BS boot_sector, uint32_t cluster_num)
{
	uint32_t data_sector = (uint32_t)boot_sector.BPB_RsvdSecCnt + ((uint32_t)boot_sector.BPB_NumFATs * boot_sector.BPB_FATSz32);
	uint32_t first_sec = ((cluster_num - 2) * boot_sector.BPB_SecPerClus) + data_sector;

	return first_sec*boot_sector.BPB_BytesPerSec;
}


//get the next cluster in the chain 
static uint32_t next_cluster(fat32BS boot_sector, uint32_t cluster_num, FILE* fp)
{
	uint8_t sec_buff[boot_sector.BPB_BytesPerSec];
	uint32_t FAT_offset;
	uint32_t FAT_ent_offset;
	uint32_t FAT_sec_num;

	FAT_offset = cluster_num * 4;
	FAT_ent_offset = FAT_offset % (uint32_t)boot_sector.BPB_BytesPerSec;
	FAT_sec_num = boot_sector.BPB_RsvdSecCnt + (FAT_offset / (uint32_t)boot_sector.BPB_BytesPerSec);

	fseek(fp, FAT_sec_num*boot_sector.BPB_BytesPerSec, SEEK_SET);
	fread(&sec_buff, sizeof(sec_buff), 1, fp);

	return (*((uint32_t *) &sec_buff[FAT_ent_offset])) & 0x0FFFFFFF;
}

//figure out how many dashes need to be printed
static char* get_string(int x)
{
	char* string = malloc(sizeof(char)*10);

	for(int i = 0; i < x; i++)
	{
		strcat(string, "-");
	}

	return string;
}



//read an entire sector
//FAT image has 512 byte sectors that can hold 16 directory structs each
void read_sector(fat32BS boot_sector, fat32Dir dir, uint32_t clus_num, FILE* fp, int x)
{
	char* string = get_string(x);
	fat32Dir super = dir;
	fat32Dir temp;


	for(uint32_t i = 0; i < boot_sector.BPB_BytesPerSec/sizeof(fat32Dir); i++)
	{
		fread(&temp, sizeof(fat32Dir), 1, fp);

		if(temp.DIR_Name[0] != 0xE5 && temp.DIR_Name[0] != 0x00)
		{	
			if(temp.DIR_Attr == 0x10)
			{	
				int temporary = ftell(fp);
				printf("%s Directory: %.8s", string, temp.DIR_Name);
				printf("\n");

				//go to the first sector of this directory and print its contents
				uint32_t fs = first_sector(boot_sector, temp.DIR_FstClusLO);
				fseek(fp, fs, SEEK_SET);
				read_sector(boot_sector, temp, temp.DIR_FstClusLO, fp, x+1);
				fseek(fp, temporary, SEEK_SET);
			}	

			else if(temp.DIR_Attr == 0x30 || temp.DIR_Attr == 0x20 || temp.DIR_Attr == 0x01 || temp.DIR_Attr == 0x04)
			{
				if(temp.DIR_Attr == 0x30)
				{
					printf("%s Directory: %.8s", string, temp.DIR_Name);
					printf("\n");
				}
				else
				{

					printf("%s File: ", string);
					for(int i = 0; i < 8; i++)
					{
						if(temp.DIR_Name[i] != 32)
						{
							printf("%c", temp.DIR_Name[i]);
						}
					}
					printf(".%.3s", temp.DIR_Ext);
					printf("\n");
				}
			}
		}
	}

	//get value from FAT for next cluster
	uint32_t check = next_cluster(boot_sector, clus_num, fp);

	//if it's valid then go to the next cluster and print its contents
	if(super.DIR_Attr == 0x10 && check < 0x0ffffff8)
	{
		uint32_t fs1 = first_sector(boot_sector, check);
		fseek(fp, fs1, SEEK_SET);
		read_sector(boot_sector, super, check, fp, x);
	}
}

void info(fat32BS boot_sector, FSInfo fs_info)
{
	//calculations for FAT info
	uint32_t to_kb = 1000;
	uint32_t free_clusters = fs_info.FSI_Free_Count;
	uint32_t free_space = (free_clusters * (uint32_t)boot_sector.BPB_SecPerClus * (uint32_t)boot_sector.BPB_BytesPerSec)/to_kb;

	uint32_t usable_space = (boot_sector.BPB_TotSec32 - (uint32_t)boot_sector.BPB_RsvdSecCnt - ((uint32_t)boot_sector.BPB_NumFATs * boot_sector.BPB_FATSz32)) 
	* (uint32_t)boot_sector.BPB_BytesPerSec;

	uint32_t bytes_per_cluster = (uint32_t)boot_sector.BPB_BytesPerSec * (uint32_t)boot_sector.BPB_SecPerClus;

	uint32_t total_bytes = (uint32_t)boot_sector.BPB_TotSec32 * (uint32_t)boot_sector.BPB_BytesPerSec;


	printf("\nInfo Command ----------------------------------\n\n");
	printf("Drive Name: %s\n", boot_sector.BS_OEMName);
	printf("Free Space: %d kb\n", free_space);
	printf("Usable Storage: %d bytes\n", usable_space);
	printf("Cluster Size: \n\tNumber of Sectors: %d\n\tNumber of bytes: %d\n", boot_sector.BPB_SecPerClus, bytes_per_cluster);
	printf("Total Bytes on Drive: %d\n", total_bytes);
}

void list(fat32BS boot_sector, FILE* fp)
{
	fat32Dir root;
	//reads root dir into root
	uint32_t root_dir = boot_sector.BPB_RootClus;
	uint32_t root_offset = first_sector(boot_sector, root_dir);
	fseek(fp, root_offset, SEEK_SET);
	fread(&root, sizeof(fat32Dir), 1, fp);

	
	printf("\nList Command ----------------------------------\n\n");
	printf("Directory: %s\n", root.DIR_Name);

	read_sector(boot_sector, root, root.DIR_FstClusLO, fp, 1);



}

//not implemented
void get()
{
	printf("\nGet Command ----------------------------------\n\n");
}

int main(int argc, char* argv[])
{
	char* args[2];

	fat32BS boot_sector;
	FSInfo fs_info;
	FILE* fp;

	if(argc == 3)
	{
	    args[0] = argv[1];
	    args[1] = argv[2];
	}
	else
	{
		printf("Please pass an image name and command when running the program.\n");
		exit(EXIT_FAILURE);
	}


	fp = fopen(args[0], "r");

	if(fp == NULL)
	{
		printf("File Not Found, please try again with another file name.\n");
		exit(EXIT_FAILURE);
	}

	fread(&boot_sector, sizeof(fat32BS), 1, fp);
	fread(&fs_info, sizeof(FSInfo), 1, fp);


	if(strcmp(args[1], "info") == 0)
	{
		info(boot_sector, fs_info);
	}
	else if (strcmp(args[1], "list") == 0)
	{
		list(boot_sector , fp);
	}
	else if (strcmp(args[1], "get") == 0)
	{
		get();
	}
	else
	{
		printf("%s is not a valid command. Try \'info\', \'list\', or \'get\'.\n", args[1]);
		exit(EXIT_FAILURE);
	}

}

