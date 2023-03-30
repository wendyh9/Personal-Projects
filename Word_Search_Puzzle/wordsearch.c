// author: Wendy Haw

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

void printPuzzle(char** arr);
void searchPuzzle(char** arr, char* word);
int bSize;
int** numArr;
	
int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <puzzle file name>\n", argv[0]);
        return 2;
    }
    int i, j;
    FILE *fptr;

    // open file for reading puzzle
    fptr = fopen(argv[1], "r");
    if (fptr == NULL) {
        printf("Cannot Open Puzzle File!\n");
        return 0;
    }

    // read the size of the puzzle block
    fscanf(fptr, "%d\n", &bSize);
    
    // allocate space for the puzzle block and the word to be searched
    char **block = (char**)malloc(bSize * sizeof(char*));
    char *word = (char*)malloc(20 * sizeof(char));

    // read puzzle block into 2D arrays
    for(i = 0; i < bSize; i++) {
        *(block + i) = (char*)malloc(bSize * sizeof(char));
        for (j = 0; j < bSize - 1; ++j) {
            fscanf(fptr, "%c ", *(block + i) + j);            
        }
        fscanf(fptr, "%c \n", *(block + i) + j);
    }
    fclose(fptr);

    printf("Enter the word to search: ");
    scanf("%s", word);
    
    // print out original puzzle grid
    printf("\nPrinting puzzle before search:\n");
    printPuzzle(block);
    
    // call searchPuzzle to the word in the puzzle
    searchPuzzle(block, word);
    
    return 0;
}

// function will print out the complete puzzle grid (arr)
void printPuzzle(char** arr) {
    for (int i = 0; i < bSize; i++){
		for (int j = 0; j < bSize; j++){
			printf("%c ", *(*(arr + i) + j));
		}
		printf("\n");
	}
}

int** numArray(){
    // creates the zero array
	int i;
    int j;
	int **arr = (int**)malloc(bSize * sizeof(int*));
	
	// create n pointers for each array
	for (i = 0; i < bSize; i++){
		*(arr + i) = (int*)malloc(bSize * sizeof(int));
	}
	
	// assign each element to be 0
	for (i = 0; i < bSize; i++){
		for (j = 0; j < bSize; j++){
			*(*(arr + i) + j) = 0;
		}
	}
    return arr;
}

// function will print out the complete puzzle grid (arr) for potential pathways
void printNumArray(int** arr) {
    for (int i = 0; i < bSize; i++){
		for (int j = 0; j < bSize; j++){
			printf("%d\t", *(*(arr + i) + j));
		}
		printf("\n");
	}
}

void lowerToUpper(char* word){
// A = 65; a = 97
// Z = 90; z = 122
    for (int i = 0; i < strlen(word); i++){
        if(*(word + i) > 96 && *(word + i) < 123){
            *(word + i) -= 32;
        }
    } 
}

bool searchLetter(char** arr, int row, int col, int k, char* word){
    int i;
    int j;

    if (k == strlen(word) - 1){
        return true;
    }

    k++;

    // looking at row before and after row index
    for (i = row - 1; i < row + 2; i++){
        // looking at col before and after col index
        for (j = col - 1; j < col + 2; j++){
            // i and j cannot be greater than bSize (right and bottom)
            // i and j have to be >= 0 (left and top)
            // i == row and j == col can't be at the same time (looks at letter that was already found)
            // next letter is found
            if (i < bSize && j < bSize && i >= 0 && j >= 0 && (!(i == row && j == col)) && *(*(arr + i) + j) == *(word + k)){
                if (searchLetter(arr, i, j, k, word) == true){
                    // letter has already been used in word
                    if (*(*(numArr + i) + j) > 0){
                        // adjust place value
                        *(*(numArr + i) + j) =  *(*(numArr + i) + j)*10 + (k + 1); 
                    }
                    // letter hasn't been used in word
                    else{
                        *(*(numArr + i) + j) = k + 1; 
                    }
                    return true;
                }
            }
        }
    }
    return false;
}

// function checks if arr contains the search word
void searchPuzzle(char** arr, char* word) {    
    int i;
    int j;
    int k = 0;
    bool found = false;
    
    numArr = numArray();

    lowerToUpper(word);

    for(i = 0; i < bSize; i++){
        for (j = 0; j < bSize; j++){
            // k = 0;
            // find first letter of word
            if (*(*(arr + i) + j) == *(word + k)){
                if (searchLetter(arr, i, j, k, word) == true){
                    // // make sure location of first letter in numArr is incremented to 1
                    // *(*(numArr + i) + j) += 1; 
                    // letter has already been used in word
                    if (*(*(numArr + i) + j) > 0){
                        // adjust place value
                        *(*(numArr + i) + j) =  *(*(numArr + i) + j)*10 + 1;
                    }
                    // letter hasn't been used in word
                    else{
                        *(*(numArr + i) + j) = 1; 
                    }
                    found = true;    
                }
            }
        }
    }

    if (found == true){
        printf("\nWord found! \n");
        printf("Printing the search path: \n");
        printNumArray(numArr);
    }
    if (found == false){
        printf("\nWord not found! \n");
    }
}

