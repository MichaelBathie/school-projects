#ifndef FSINFO_H
#define FSINFO_H

#include <inttypes.h>


#pragma pack(push)
#pragma pack(1)
struct FSInfo_struct 
{
	uint32_t FSI_LeadSig;
  	uint8_t FSI_Reserved1[480];
  	uint32_t FSI_StrucSig;
  	uint32_t FSI_Free_Count;
  	uint32_t FSI_Nxt_Free;
  	uint8_t FSI_Reserved2[12];
  	uint32_t FSI_TrailSig;
};
#pragma pack(pop)

typedef struct FSInfo_struct FSInfo;

#endif