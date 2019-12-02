#include <stdio.h> 
#include <stdlib.h>
#include <string.h>

int computeOpCode(int op1, int op2, int op3, int op4, int* program){
    if(op1==1){
        int result = program[op2]+program[op3];
        program[op4] = result;
        return 0;
    }else if(op1 == 2){
        int result = program[op2]*program[op3];
        program[op4] = result;
        return 0;
    }else if(op1 == 99){
        return 1;
    }
    return 1;
}

int main(void){
    char * buffer = 0;
    long length;
    FILE * f = fopen ("input.txt", "rb");

    if (f){
        fseek (f, 0, SEEK_END);
        length = ftell (f);
        fseek (f, 0, SEEK_SET);
        buffer = malloc (length);
        if (buffer){
            fread (buffer, 1, length, f);
        }
        fclose (f);
    }else{
        printf("\nno file handle");
    }

    if (buffer){
        char delimiter[] = ",";
        char *ptr;
        int counter = 0;
        int pc = 0;
        int* intCodes = malloc(length*4);

        // initialisieren und ersten Abschnitt erstellen
        ptr = strtok(buffer, delimiter);

        while(ptr != NULL) {
            intCodes[counter] = atoi(ptr);

            // naechsten Abschnitt erstellen
            ptr = strtok(NULL, delimiter);

            counter++;
        }
        
        printf("\ncounter: %d", counter);


        printf("\nintcodes: ");
        for(int i = 0; i < counter; i++){
            printf("%d, ", intCodes[i]);
        }

        int halt = 0;
        while(pc < counter && !halt){
            halt = computeOpCode(intCodes[pc], intCodes[pc+1], intCodes[pc+2], intCodes[pc+3], intCodes);
            pc = pc + 4;
            printf("\npc: %d", pc);
            printf("\nhalt: %d", halt);
        }

        printf("\npc: %d", pc);

        printf("\nintcodes: ");
        for(int i = 0; i < counter; i++){
            printf("%d, ", intCodes[i]);
        }
    }else{
        printf("\nno buffer!");
    }
    return 0;
}