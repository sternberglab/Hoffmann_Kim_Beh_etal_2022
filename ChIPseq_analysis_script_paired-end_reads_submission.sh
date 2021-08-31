###########################################################
## Florian T. Hoffmann | Last updated: August 29, 2021   ##
## Columbia University, Sternberg Lab                    ##
## Title: ChIPseq_analysis_script_paired-end_reads.sh    ##
###########################################################

# Required Command line packages for this script (these need to be installed prior to running this script):
    # fastp (available through conda; bioconda channel)
    # Bowtie 2 (downloaded latest version from http://bowtie-bio.sourceforge.net/bowtie2/index.shtml and placed into the conda packages directory because the conda version did not work)
    # Samtools (installed manually since bioconda did not work)
    # MACS2 (available through conda; bioconda channel)
    # deepTools (available through conda; bioconda channel)
    # NOTE 1: conda packages can be found in this directory: cd /Users/florian/opt/anaconda3/pkgs
    # NOTE 2: If the 'conda' command cannot be executed, add conda to the PATH again: export PATH=/Users/florian/miniconda3/bin:$PATH

# RAW DATA:
    # All my sequencing run data can be found here: cd /Users/florian/BaseSpace.
    # Sequencing data folders are named as follows: date_lab_sequencer, e.g. 121820_Sternberg_MiniSeq.

# BEFORE YOU START: 
    # 1. This script is written for processing paired-end reads and needs to be modified (for fastp, Bowtie 2) for processing single-end reads.
    # 2. This script requires lanes to be merged already (use 'merge_lanes.sh' file if you have not merged the '.fastq.gz' files yet).
    # 3. Rename the folder that contains the .fastq files (e.g. change it to '121820_Sternberg_MiniSeq') (optional).
    # 4. Delete all BaseSpace ID folders that are not yours/that were created due to contamination (all folders that you do not want to have analyzed).
    # 5. Please update the file path in the command (Step 1.7) below before executing this script, and save the script.
    # 6. Please update the directory in which Bowtie 2 was installed (Step 1.5).
    # 7. Create a folder in your working directory (must be same as $PWD/..) named 'reference_genome' and place your reference genome (in '.fasta' format) in there.
    # 8. Execute this bash file by navigating to the directory of this script and typing 'sh ChIPseq_analysis_script'.
    # 9. Interrupt the running script at any time by pressing ctrl + c.

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

    # Step 1.4: 'Welcome' and 'Before you start' notes.
    # First, print a welcome message stating the title and author of this shell script.
    # Secondly, let shell pause ('sleep' command) for a few second between  printing text, so the user can read it.
    # Then, ask the user of the script if they have read and understood the 'BEFORE YOU START' notes.
    # A 'Y' or 'y' input will allow the script to run.
    # A 'N' or 'n' input will terminate the script and the user can perform the steps outlined in the 'BEFORE YOU START' notes.

    echo ""
    echo ""
    echo ""
    echo "Welcome to the ChIP-seq analysis Unix shell script."
    echo ""
    echo ""
    echo ""
    
    ### Steps skipped to speed up the script ###

    # Step 1.5: Prepare the environment for the package Bowtie 2.
    # The Bowtie 2 home directory (named 'BT2_HOME') must be set to where the package got installed. 
    # The directory must be that of the Bowtie 2 'bin' folder.
    # The 'echo' command will print the set 'BT2_HOME' home directory upon execution of this script.

    BT2_HOME="/Users/florian/opt/anaconda3/pkgs/bowtie2-2.4.2"
    echo "Your Bowtie 2 home directory ('BT2_HOME') is set to:" $BT2_HOME

    # Step 1.6: Add Samtools to the PATH (MacOS).
    # This command will make Samtools executable for bash.

    export PATH=/Users/florian/samtools-1.11/bin:$PATH
    echo "'Samtools' has been added to the PATH."
    
    # Step 1.7: Set the working directory.
    # Update the directory below every time.
    # The 'echo' command will print the set working directory upon execution of this script.

    cd /Users/florian/BaseSpace/121820_Sternberg_MiniSeq
    echo "Your working directory is set to:" $PWD

    # Step 1.8: Create a directory into which a log file of all Terminal outputs will be placed.

    mkdir -p $PWD/run_log

############################################
### STEP 2: Prepare the 'fastq.gz' files ###
############################################

    # Step 2.1: Duplicate the 'fastQ_files' folder and its contents, so there is a back-up.
    # (In case the code messes up the files.)

    cp -rp $PWD/fastQ_files/. $PWD/fastQ_files_backup/

    # Step 2.2: Set the working directory to the 'fastQ_file' folder.
    # Upon execution of this script, the 'echo' command will print that working directory has been changed in this step.

    cd $PWD/fastQ_files
    echo "Your working directory has been updated to:" $PWD

    # Step 2.3: Each '.fastq.gz' file is packaged into a folder. This folder is redundant for the analysis.
    # Thus, this folder (once empty) can be deleted later.
    # Extract the '.fastq.gz' files from that folder and place them into the parent folder.

    find . -name '*.fastq.gz' -exec mv {} $PWD/ \;

    # Step 2.4: The folder is empty now.
    # Delete the empty folder.

    find . -depth -type d -empty -exec rmdir {} \;

    # Step 2.5: The commands below shortens '.fasq.gz' file names of .fastq files.
    # Only the BaseSpace ID (Starting with 'A4...') and the read ID are kept as the file name.
    # (In the paired-end mode, two reads are generated for each sample, so one has the ID '1' the other '2'.)
    # For example, a file named 'A4414_S19_L001_R1_001.fastq.gz' will be converted into a file named 'A4414_1'.
    # The new shortened file names will be printed using the 'echo' command.

    for i in A*; do mv "$i" "${i/_S?_L001_R1_001/_1}"; done
    for i in A*; do mv "$i" "${i/_S?_L001_R2_001/_2}"; done
    for i in A*; do mv "$i" "${i/_S??_L001_R1_001/_1}"; done
    for i in A*; do mv "$i" "${i/_S??_L001_R2_001/_2}"; done
    for i in A*; do mv "$i" "${i/_S???_L001_R1_001/_1}"; done
    for i in A*; do mv "$i" "${i/_S???_L001_R2_001/_2}"; done

    for i in A*; do echo "$i"; done

#############################################################
### STEP 3: Trim and quality-filter the reads using fastp ###
#############################################################

    # Step 3.1: Create a new folder into which trimmed reads will be saved.
    # The folder will be named 'fastQ_files_trimmed'

    mkdir -p $PWD/../fastQ_files_trimmed

    # Step 3.2: Use fastp to trim and quality filter the reads.
    # Use default parameters.
    # When using paired-end reads, use -i and -o for the first read.
    # And use -I and -O for the second read.
    # When usign single-end reads, only use -i and -o and delete -I and -O.

    for i in *1.fastq.gz; do fastp -i "$i" -I "${i/_1/_2}" -o "${i/_1/_1_trimmed}" -O "${i/_1/_2_trimmed}" -j "${i/_1.fastq.gz/_trimmed}".json -h "${i/_1.fastq.gz/_trimmed}".html; done

    # Step 3.3: Move the trimmed reads generated above (Step 2.2) into the 'fastQ_files_trimmed' folder.
    # Step 3.2 also created summary files: '_trimmed.html' and '_trimmed.json'.
    # This command also moves the summary files into the same folder due to similar naming.

    mv $PWD/A*trimmed* $PWD/../fastQ_files_trimmed

#########################################################################################
### STEP 4: Index reference genome and align reads to reference genome using Bowtie 2 ###
#########################################################################################

    # Step 4.1: Create a directory into which the indexed reference genome will be placed.

    mkdir -p $PWD/../reference_genome_indexed

    # Step 4.2: Change into the newly created directory. 
    # Bowtie 2 will deposit the indexed reference genome in the directory that you are currently in.
    # Upon execution of this script, the 'echo' command will print that working directory has been changed in this step.

    cd $PWD/../reference_genome_indexed
    echo "Your working directory has been updated to:" $PWD
    
    # Step 4.3: Index the reference genome.
    # This command generates 6 output files that end in '.bt2'.
    # The first part (starting with '$BT2_HOME/') of this command locates the file encoding the 'bowtie2-build' command.
    # The second part (starting with '$PWD/') of this command locates the unindexed reference genome. '*.fasta' indicates that any file ending in '.fasta' will be used.
    # The third/last part (strating with 'indexed') of this command determines the names of the indexing output files.
   
    $BT2_HOME/bowtie2-build $PWD/../reference_genome/*.fasta indexed_genome

    # Step 4.4: Create a directory into which the aligned reads will be placed.

    mkdir -p $PWD/../reads_aligned_sam

    # Step 4.5: Change into the 'fastQ_files_trimmed' directory.
    # Bowtie 2 will deposit the aligned reads into this directory in the next step.
    # Upon execution of this script, the 'echo' command will print that working directory has been changed in this step.

    cd $PWD/../fastQ_files_trimmed
    echo "Your working directory has been updated to:" $PWD

    # Step 4.6: Align paired-end reads to the indexed reference genome.
    # This command generates '.sam' output files. 
    # The first part (starting with '*1_trimmed.fastq.gz') of this command marks all read '1' files relevant for the 'for loop'.
    # The second part (starting with 'echo') of this command prints what file is being processed.
    # The third part (starting with '$BT2_HOME/') of this command locates the file encoding the 'bowtie2' command.
    # The fourth part (starting with '$PWD/../reference') of this command locates the folder containing the indexed reference genome files.
    # The fifth part (starting with '-1 $PWD/../fastQ') of this command locates read '1' of the paired-end reads.
    # The sixth part (starting with '-2 $PWD/../fastQ') of this command locates read '2' of the paired-end reads.
    # The seventh/last part (starting with '-S') of this command determines the names of the aligning output files and puts them into the '$PWD/../reads_aligned' directory.
    
    for i in *1_trimmed.fastq.gz; do echo ""; echo ""; echo "The file $i is being aligned..."; echo ""; echo ""; $BT2_HOME/bowtie2 -x $PWD/../reference_genome_indexed/indexed_genome -1 "$i" -2 "${i/_1/_2}" -S $PWD/../reads_aligned_sam/"${i/_1_trimmed.fastq.gz/_aligned}".sam; done

##############################################################################################################################
### STEP 5: Convert '.sam' files into '.bam' files, sort and index files, and eliminate multi-mapping reads using Samtools ###
##############################################################################################################################

    # Step 5.1: Create a directory into which the '.bam' files will be placed.

    mkdir -p $PWD/../reads_aligned_bam

    # Step 5.2: Change into the directory that contains the '.sam' files.
    # Samtools will use '.sam' files in this directory and generate '.bam' files in the next step.
    # Upon execution of this script, the 'echo' command will print that working directory has been changed in this step.

    cd $PWD/../reads_aligned_sam
    echo "Your working directory has been updated to:" $PWD
    
    # Step 5.3: Convert '.sam' files into '.bam' files using the 'samtools view' command.
    # The '-b' option is used to produce '.bam' output files.
    # This step is required since IGV does not accept '.sam' input files.
    
    for i in *aligned.sam; do samtools view -b "$i" > $PWD/../reads_aligned_bam/"${i/_aligned.sam/_aligned.bam}"; done

    # Step 5.4: Create a directory into which the sorted '.bam' and index '.bai' files will be placed.
    # This directory will later contain the unfiltered (i.e. multi-mapping) '.bam' reads and their corresponding index '.bai' files.

    mkdir -p $PWD/../unfiltered_reads_aligned_sorted_bam_bai
    
    # Step 5.5: Change into the directory that contains the unsorted '.bam' files.
    # Samtools will use files in this directory in the next step.
    # Upon execution of this script, the 'echo' command will print that working directory has been changed in this step.

    cd $PWD/../reads_aligned_bam
    echo "Your working directory has been updated to:" $PWD
    
    # Step 5.6: Sort the '.bam' files using the 'samtools sort' command.
    # By default, this command will create '.bam' output files because the input files are in the '.bam' format.
    # This command also creates temporary '.tmp.0000.bam' files that will get deleted automatically prior to completion of this command.
    
    for i in *aligned.bam; do samtools sort -o $PWD/../unfiltered_reads_aligned_sorted_bam_bai/"${i/_aligned/_aligned_sorted}" "$i"; done 

    # Step 5.7: Change into directory that contains the aligned and sorted but unfiltered '.bam' files.
    # Upon execution of this script, the 'echo' command will print that working directory has been changed in this step.

    cd $PWD/../unfiltered_reads_aligned_sorted_bam_bai
    echo "Your working directory has been updated to:" $PWD
    
    # Step 5.8: Index the aligned and sorted but unfiltered '.bam' files using the 'samtools index' command.
    # This command generates '.bai' output files that are required to exist in order fro IGV to visualize '.bam' files.
    # The '.bai' files will be placed into the same directory, so that they can be easily found later by IGV (which searches for '.bai' files associated with '.bam' files in the same directory).
    # The '-b' option is used to produce '.bai' output files.

    for i in *aligned_sorted.bam; do samtools index -b "$i" "${i/_aligned_sorted.bam/_aligned_sorted.bam.bai}"; done

    # Step 5.9: Create a directory into which the aligned, sorted and filtered (uniquely mapping) '.bam' files and their corresponding '.bai' files will be placed.

    mkdir -p $PWD/../filtered_reads_aligned_sorted_bam_bai
    
    # Step 5.10: Eliminate multi-mapping reads (filtering) using the 'samtools view' command.
    # This command will eliminate all multi-mapping reads and will only retain uniquely-mapping reads.
    # The '-q' option is set to '10', so that all reads with a MAPQ score < 10 will be eliminated. Only reads with a MAPQ score >= 10 will be retained.
    # The '-b' option is used to produce '.bam' output files.

    for i in *aligned_sorted.bam; do samtools view -bq 10 "$i" > $PWD/../filtered_reads_aligned_sorted_bam_bai/"${i/_aligned_sorted.bam/_aligned_sorted_filtered.bam}"; done

    # Step 5.11: Change into the directory that contains the 'aligned_sorted_filtered.bam' reads.
    # Samtools will use files in this directory to create their index '.bai' files in the next step.
    # Upon execution of this script, the 'echo' command will print that working directory has been changed in this step.

    cd $PWD/../filtered_reads_aligned_sorted_bam_bai
    echo "Your working directory has been updated to:" $PWD
    
    # Step 5.12: Create index '.bai' files for the unique (filtered), aligned and sorted reads.
    # This is required in order for IGV to accept '.bam' files.
    # The '.bai' output files will be placed into the same folder in which the 'aligned_sorted_filtered.bam' files were deposited, so that IGV can find the '.bai' file for each '.bam' file easily.

    for i in *aligned_sorted_filtered.bam; do samtools index -b "$i" "${i/_aligned_sorted_filtered.bam/_aligned_sorted_filtered.bam.bai}"; done

##################################################################
### STEP 6: Delete all files redundant for downstream analysis ###
##################################################################

    # Step 6.1: Print a message telling the user that all intermediate/redundant folders will be deleted.
    # Print the list of folders that will be deleted.

    echo ""
    echo "To reduce memory usage of your local computer, the following folders will be deleted:"
    echo ""
    echo "1. 'fastQ_files'         | file size:" 
    du -hs $PWD/../fastQ_files 
    echo ""
    echo "2. 'fastQ_files_trimmed' | file size:" 
    du -hs $PWD/../fastQ_files_trimmed
    echo ""
    echo "3. 'reads_aligned_sam'   | file size:" 
    du -hs $PWD/../reads_aligned_sam
    echo ""
    echo "4. 'reads_aligned_bam'   | file size:" 
    du -hs $PWD/../reads_aligned_bam
    echo ""

    # Step 6.2: Delete the folders including their contents.

    #rm -r $PWD/../fastQ_files
    #rm -r $PWD/../fastQ_files_trimmed
    #rm -r $PWD/../reads_aligned_sam
    #rm -r $PWD/../reads_aligned_bam

########################################################
### STEP 7: End of ChIP-seq paired-end read analysis ###
########################################################

    # Step 7.1: Print the names of all aligned, sorted and filtered '.bam' output files that were generated.
    # This will show the user that the analysis has been successful.
    # The directory of the uniquely-mapping reads can be found will also be printed.
    
    echo ""
    echo ""
    echo ""
    echo "The following uniquely-mapping read files have been generated:"
    echo ""

    for i in *_aligned_sorted_filtered.bam; do echo "$i"; done

    echo ""
    echo "Directory of uniquely-mapping reads:" $PWD

    # Step 7.2: Print a note saying that the '.bam' files should be binned in IGV (using 'count' option) after finishing this script.
    
    echo ""
    echo ""
    echo "In the next step, please manually convert the '.bam' files of the filtered reads into '.tdf' files using the IGV option 'count'." 
    echo "To find 'count', open IGV, navigate to the tab 'Tools' and select 'Run igvtools...'."
    echo "Set the 'Window Size' to 1."
    echo ""
    echo ""

    # Step 7.3: Create folders for the optional normalization step.
    # Normalization can be performed using the separate Bash script named 'Normalization_ChIPseq_analysis_script.sh' that can be found in the 'Bioinformatics' folder under 'Bash Scripts'.
    # Here, we are creating a subfolder called 'normalization'. In addition we create a folder within the 'normalization' folder named 'input'.
    # By printing the directory, the user will know where they can manually place files for normalization.

    mkdir -p $PWD/../normalization
    mkdir -p $PWD/../normalization/input

    cd $PWD/../normalization

    echo ""
    echo ""
    echo "A directory for normalization has been created:" $PWD
    echo "Normalization can be performed by running a separate script named 'Normalization_ChIPseq_analysis_script.sh"
    echo ""
    echo ""

    # Step 7.4: Stop the timer and print how long the execution of this script has taken.

    ELAPSED_TIME=$(($SECONDS - $START_TIME))

    echo "Runtime of this analysis: $(($ELAPSED_TIME/60)) min $(($ELAPSED_TIME%60)) sec"  

    # Step 7.5: Remind the user to save the terminal output after running this script.

    echo ""
    echo "REMINDER: Please save the Terminal output in a file."
    echo "The file will contain the read filtering details and error messages."
    echo "A folder named 'run_log' has been generated for this purpose."
    echo ""

    # Step 7.6: Print end note.

    echo ""
    echo ""
    echo "END OF SCRIPT"
    echo ""
    echo ""

#####################
### END OF SCRIPT ###
#####################

###########################################################################################################################################################################################################################################################################################################
    
### THINGS TO OPTIMIZE: ###

# 1. Once the script has finished, save the text that has been generated in the Terminal as a summary '.txt' file.

# 2. Modify code in order to run it on AWS EC2. This requires all packages to be installed on EC2.

# 3. Add code that automatically converts filtered '.bam' files into '.tdf' files using the command line version of igvtools.
