#!/usr/bin/perl -w
# run the script: time perl 00.script/01.folder.fastaCombinePairedEnd.pl  01.data/01.Fastq Sapelo

use strict;
system("echo 'Running 01.folder.fastaCombinePairedEnd.pl ....' >> job.monitor.txt");

## read in parameters required by the script
my $srcfolder = shift @ARGV;
my $separater = shift @ARGV || " ";
my $platform = lc(shift @ARGV);
my $thread = 1;

## start running the script
system("mv fastx.fastq2fasta.* 00.script/shell.script");
system("rm -rf 00.script/shell.script.previous");
system("mv 00.script/shell.script 00.script/shell.script.previous");
system("mkdir -p 00.script/shell.script");

opendir(SRC, $srcfolder) or die "ERROR: Cannot open $srcfolder: $!";
my @subs = sort(grep(/\w+/, readdir(SRC)));		## extract sample names

system("rm -f flag*");

foreach my $sub (@subs){
	if($sub =~ /F$|Fu$|R$/){	## only for specific samples in 454, can be removed
		next;
	}
	my $shell = "00.script/shell.script/fastaCombinePairedEnd.$sub.sh";
	open(SHL, ">$shell") or die "ERROR: Cannot write $shell: $!";
	
	if($platform eq "sapelo"){
	    print SHL "#PBS -S /bin/bash\n";
	    print SHL "#PBS -q batch\n";
	    print SHL "#PBS -N fastaCombinePairedEnd.$sub\n";
	    print SHL "#PBS -l nodes=1:ppn=$thread:AMD\n";
	    print SHL "#PBS -l walltime=6:00:00\n";
	    print SHL "#PBS -l mem=20gb\n";
		print SHL "\n";
		print SHL "cd \$PBS_O_WORKDIR\n";
	}elsif($platform eq "zcluster"){
		print SHL "#!/bin/bash\n";
	}else{
		die "Please provide the platform: 'Sapelo' or 'Zcluster'";
	}

	if($platform eq "sapelo"){
		print SHL "module load anaconda/2.2.0\n";
	}elsif($platform eq "zcluster"){
		print SHL "export PYTHONPATH=/usr/local/python/2.7.8/lib/python2.7:/usr/local/python/2.7.8/lib/python2.7/site-packages\n";
	}else{
		die "Please provide the platform: 'Sapelo' or 'Zcluster'";
	}
	print SHL "time python2.7 00.script/01.fastaCombinePairedEnd.py $srcfolder/$sub/$sub.R1.fastq $srcfolder/$sub/$sub.R2.fastq $separater\n";
	print SHL "echo You may proceed! >> flag$sub.txt";

	close SHL;
	
	system("chmod u+x $shell");
	if($platform eq "sapelo"){
    	system("qsub $shell");
	}elsif($platform eq "zcluster"){
		system("qsub -q rcc-30d -pe thread $thread $shell");
	}else{
		die "Please provide the platform: 'Sapelo' or 'Zcluster'";
	}
}

foreach my $sub (@subs) {
while (not -e "flag$sub.txt") {sleep 5};
}

close SRC;

system("echo 'Finished 01.folder.fastaCombinePairedEnd.pl!' >> job.monitor.txt");
system("chmod 777 -R 01.data/01.Fastq");
system("chmod 777 -R 01.data/02.Fasta");
system("chmod 777 -R 00.script");

