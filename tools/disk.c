#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define MIN(X, Y) (((X) < (Y)) ? (X) : (Y))

int main(int argc, char ** argv) {
    if (argc < 2) {
		fprintf(stderr, "Provide a file to convert to an assembly header\n");
		return 1;
	}

	FILE * fp = fopen(argv[1], "rb");
	if (fp == NULL) {
		fprintf(stderr, "Failed to open file %s\n", argv[1]);
		return 1;
	}

	fseek(fp, 0L, SEEK_END);
	size_t length = ftell(fp);
	fseek(fp, 0L, SEEK_SET);

	uint8_t * buffer = malloc(sizeof(uint8_t) * length + 1);
	if (buffer == NULL) {
		fprintf(stderr, "Failed to malloc size %zu\n", length);
		return 1;
	}

	if (fread(buffer, 1, length, fp) != length) {
		fprintf(stderr, "File read error\n");
		return 1;
	}

	fclose(fp);

	fprintf(stdout, "dd 0x%X\n", 0x6B726973);
	fprintf(stdout, "dd 0x%X\n", (uint32_t) length);

	uint8_t filename[16];
	memset(filename, ' ', sizeof(uint8_t) * 16);
	memcpy(filename, argv[1], MIN(strlen(argv[1]), 16));
	fprintf(stdout, "db '%.16s'\n", filename);

	const char hexchars[16] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };

	uint8_t byte = 0;
	uint64_t qword = 0;
	for (size_t i = 0; i < length / 8; ++i) {
		qword = ((uint64_t *) buffer)[i];
		fputs("dq 0x", stdout);
		byte = qword >> 56;
		fprintf(stdout, "%c%c", hexchars[byte >> 0x04], hexchars[byte & 0x0F]);
		byte = qword >> 48;
		fprintf(stdout, "%c%c", hexchars[byte >> 0x04], hexchars[byte & 0x0F]);
		byte = qword >> 40;
		fprintf(stdout, "%c%c", hexchars[byte >> 0x04], hexchars[byte & 0x0F]);
		byte = qword >> 32;
		fprintf(stdout, "%c%c", hexchars[byte >> 0x04], hexchars[byte & 0x0F]);
		byte = qword >> 24;
		fprintf(stdout, "%c%c", hexchars[byte >> 0x04], hexchars[byte & 0x0F]);
		byte = qword >> 16;
		fprintf(stdout, "%c%c", hexchars[byte >> 0x04], hexchars[byte & 0x0F]);
		byte = qword >> 8;
		fprintf(stdout, "%c%c", hexchars[byte >> 0x04], hexchars[byte & 0x0F]);
		byte = qword;
		fprintf(stdout, "%c%c", hexchars[byte >> 0x04], hexchars[byte & 0x0F]);
		fputc('\n', stdout);
	}
	
	size_t newlen = length % 8;
	size_t diff = length - newlen;
	uint32_t dword = 0;
	for (size_t i = 0; i < newlen / 4; ++i) {
		dword = ((uint32_t *) (((size_t) buffer) + diff))[i];
		fputs("dd 0x", stdout);
		byte = dword >> 24;
		fprintf(stdout, "%c%c", hexchars[byte >> 0x04], hexchars[byte & 0x0F]);
		byte = dword >> 16;
		fprintf(stdout, "%c%c", hexchars[byte >> 0x04], hexchars[byte & 0x0F]);
		byte = dword >> 8;
		fprintf(stdout, "%c%c", hexchars[byte >> 0x04], hexchars[byte & 0x0F]);
		byte = dword;
		fprintf(stdout, "%c%c", hexchars[byte >> 0x04], hexchars[byte & 0x0F]);
		fputc('\n', stdout);
	}
	
	newlen = newlen % 4;
	diff = length - newlen;
	uint16_t word = 0;
	for (size_t i = 0; i < newlen / 2; ++i) {
		word = ((uint16_t *) (((size_t) buffer) + diff))[i];
		fputs("dw 0x", stdout);
		byte = word >> 8;
		fprintf(stdout, "%c%c", hexchars[byte >> 0x04], hexchars[byte & 0x0F]);
		byte = word;
		fprintf(stdout, "%c%c", hexchars[byte >> 0x04], hexchars[byte & 0x0F]);
		fputc('\n', stdout);
	}
	
	newlen = newlen % 2;
	diff = length - newlen;
	for (size_t i = 0; i < newlen; ++i) {
		byte = buffer[diff + i];
		fprintf(stdout, "db 0x%c%c\n", hexchars[byte >> 0x04], hexchars[byte & 0x0F]);
	}

    return 0;
}