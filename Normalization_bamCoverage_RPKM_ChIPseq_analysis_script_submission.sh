######################################################################
## Florian T. Hoffmann | Last updated: August 29, 2021              ##
## Columbia University, Sternberg Lab                               ##
## Title: Normalization_bamCoverage_RPKM_ChIPseq_analysis_script.sh ##
######################################################################

# Required Command line packages for this script (these need to be installed prior to running this script):
    # deepTools (available through conda; bioconda channel)
    # NOTE 1: conda packages can be found in this directory: cd /Users/florian/opt/anaconda3/pkgs
    # NOTE 2: If the 'conda' command cannot be executed, add conda to the PATH again: export PATH=/Users/florian/miniconda3/bin:$PATH

# RAW DATA:
    # All my sequencing run data can be found here: cd /Users/florian/BaseSpace.
    # Sequencing data folders are named as follows: date_lab_sequencer, e.g. 121820_Sternberg_MiniSeq.

# BEFORE YOU START:
    # 1. This script requires the ChIP-seq data analysis (i.e. mapping of reads to a reference genome) to be completed already as it requires '.bam' files as its input.
    # 2. Prior to running this script, please create a folder called 'normalization'. Into this folder, paste the '.bam' and '.bai' files of the samples that you want to be normalized. Note, this script requires the presence of the index ('.bai') file for each '.bam' file.
    # 3. Create a folder in the 'normalization' folder called 'input'. Copy and paste your input '.bam' and '.bai' file in there.
    # 4. Please update the file path in the command (Step 1.5) below before executing this script, and save the script. Use the file path of the 'normalization' folder (created in step above) as the working directory.
    # 5. Execute this bash file by navigating to the directory of this script and typing 'sh Normalization_ChIPseq_analysis_script.sh'.
    # 6. Interrupt the running script at any time by pressing ctrl + c.
    # 7. You can read up on different normalization methods available in deeptools here: https://github.com/deeptools/deepTools/wiki/Normalizations.

###########################################################################################################################################################################################################################################################################################################

#######################
### START OF SCRIPT ###
#######################

#################################################################################################
### STEP 1: Print a welcome message, prepare the coding environment and command line packages ###
#################################################################################################

    # Step 1.1: Define the script as a bash script.

    #!/bin/sh   
    
    # Step 1.2: Start a timer for this script.
    # At the end of the script, a command will print how long it has taken to run the full scrip.

    START_TIME=$SECONDS
    
    # Step 1.3: clear the Terminal window.

    clear

    # Step 1.4: Print welcome message.

    echo ""
    echo "Script for normalizing .bam files using coverage"
    echo ""

    # Step 1.5: Set the working directory.
    # Update the directory below every time.
    # The 'echo' command will print the set working directory upon execution of this script.

    cd /Users/florian/BaseSpace/052021_Sternberg_NextSeq/normalization
    echo "Your working directory is set to:" $PWD

######################################################
### STEP 2: Normalize '.bam' files using deepTools ###
######################################################

    # Step 2.1: Create a directory into which the normalized read files will be placed.
    
    mkdir -p $PWD/bamCoverage-normalized-RPKM_filtered_aligned_sorted_reads_bigwig

    # Step 2.2: Use the 'bamCoverage' command to normalize your '.bam' files.
    # Use aligned (to the reference genome), sorted and filtered (i.e. uniquely mapping) reads as input.
    # This command requires only the ChIP '.bam' files to normalize according to genome-wide reads.
    # The ChIP sample '.bam' file should be referenced after '-b1'.
    # The output will be a '.bigwig' ('.bw') file that can be imported into IGV for visualization.
    # We normalize using 'reads per kilobase per million mapped reads (RPKM)'. Usage of this parameter does not require the effective (i.e. mappable) genome size as input. (After subtracting the 1,502 (lacZ/lacI adjacent to target-4) and 1,790 Ns (lacZ/lacI in prophage) replacing the lacZ gene, this number is 4,558,953 bp - (1,502 + 1,790) bp = 4,555,661 bp.)
    # The output will be a '.bigwig' ('.bw') file that can be imported into IGV for visualization. 
    # The bin size is set to '1' using '-bs 1'. This bin size can be used because the E. coli genome is small and does not require much computational power.

    for i in *aligned_sorted_filtered.bam; do bamCoverage --normalizeUsing RPKM --effectiveGenomeSize 4555661 -bs 1 -b "$i" -o $PWD/bamCoverage-normalized-RPKM_filtered_aligned_sorted_reads_bigwig/"${i/_filtered.bam/_filtered_normalized-bamCoverage-RPKM}".bw; done

#####################################################
### STEP 3: End of paired-end read merging script ###
#####################################################

    # Step 3.1: Stop the timer and print how long the execution of this script has taken.
    
    ELAPSED_TIME=$(($SECONDS - $START_TIME))

    echo ""
    echo "Runtime of script: $(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"  
    echo ""

    sleep 2

    # Step 3.2: Remind the user to save the terminal output after running this script.

    echo ""
    echo "REMINDER: Please save the Terminal output in a file."
    echo "The file will contain the read filtering details and error messages."
    echo "A folder named 'run_log' has been generated for this purpose."
    echo ""

    # Step 3.3: Print end note.

    echo ""
    echo ""
    echo "END OF SCRIPT"
    echo ""
    echo ""

#####################
### END OF SCRIPT ###
#####################

###########################################################################################################################################################################################################################################################################################################