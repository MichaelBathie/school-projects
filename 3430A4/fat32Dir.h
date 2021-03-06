#ifndef FAT32DIR_H
#define FAT32DIR_H

#include <inttypes.h>

#define DIR_NAME_LENGTH 8
#define DIR_EXT_LENGTH 3

#pragma pack(push)
#pragma pack(1)
struct fat32Dir_struct 
{
	uint8_t DIR_Name[DIR_NAME_LENGTH];
	uint8_t DIR_Ext[DIR_EXT_LENGTH];
	uint8_t DIR_Attr;
	uint8_t DIR_NTRes;
	uint8_t DIR_CrtTimeTenth;
	uint16_t DIR_CrtTime;
	uint16_t DIR_CrtDate;
	uint16_t DIR_LastAccDate;
	uint16_t DIR_FstClusHI;
	uint16_t DIR_WrtTime;
	uint16_t DIR_WrtDate;
	uint16_t DIR_FstClusLO;
	uint32_t DIR_FileSize;
};
#pragma pack(pop)

typedef struct fat32Dir_struct fat32Dir;

#endif