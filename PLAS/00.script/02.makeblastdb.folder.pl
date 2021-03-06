#!/usr/bin/perl -w
# run the script: time perl 00.script/02.makeblastdb.folder.pl 01.data/05.Split/01.Protein/run.0 prot Sapelo

use strict;
system("echo 'Running 02.makeblastdb.folder.pl ....' >> job.monitor.txt");

my $srcfolder = shift @ARGV;
my $seqtype = shift @ARGV;
my $diamond = uc shift @ARGV;
my $platform = lc(shift @ARGV);
my $thread = 1;

opendir(SRC, $srcfolder) or die "ERROR: Cannot open $srcfolder: $!";
my @subs = sort(grep(/^[0-9]+/, readdir(SRC)));		## extract subdirectory name

system("mkdir -p 00.script/shell.script");
system("rm -f flag*");

foreach my $sub (@subs){	## loop over each subdirectory
	my $shell = "00.script/shell.script/makeblastdb.$sub.sh";
	open(SHL, ">$shell") or die "ERROR: Cannot write $shell: $!";
	if($platform eq "sapelo"){
	    print SHL "#PBS -S /bin/bash\n";
	    print SHL "#PBS -q batch\n";
	    print SHL "#PBS -N 00.script/shell.script/makeblastdb.$sub\n";
	    print SHL "#PBS -l nodes=1:ppn=$thread:AMD\n";
	    print SHL "#PBS -l walltime=1:00:00\n";
	    print SHL "#PBS -l mem=2gb\n";
		print SHL "\n";
		print SHL "cd \$PBS_O_WORKDIR\n";
	}elsif($platform eq "zcluster"){
		print SHL "#!/bin/bash\n";
	}else{
		die "Please provide the platform: 'Sapelo' or 'Zcluster'";
	}
    
    my $command1 = 0;
    my $command2 = 0;
	if($platform eq "sapelo"){
		$command1 = "/usr/local/apps/ncbiblast+/2.2.29/bin";
		$command2 = "/usr/local/apps/diamond/0.7.9/bin";
    	print SHL "module load anaconda/2.2.0  boost/gcc447/1.57.0 zlib/gcc447/1.2.8\n";
    }elsif($platform eq "zcluster"){
		$command1 = "/usr/local/ncbiblast+/2.2.29/bin";
		$command2 = "/usr/local/diamond/0.6.12/bin";
	}else{
		die "Please provide the platform: 'Sapelo' or 'Zcluster'";
	}
    
	print SHL "time $command1/makeblastdb -in $srcfolder/$sub/$sub.fasta -dbtype ",$seqtype,"\n";
	if($diamond eq "DIAMOND"){
		print SHL "time $command2/diamond makedb --in $srcfolder/$sub/$sub.fasta -d $srcfolder/$sub/$sub\n";
	}
	print SHL "echo You may proceed! >> FLAGFILE.txt";
	
	close(SHL);
	
	system("chmod u+x $shell");
	if($platform eq "sapelo"){
    	system("qsub $shell");
	}elsif($platform eq "zcluster"){
		system("qsub -q rcc-30d -pe thread $thread $shell");
	}else{
		die "Please provide the platform: 'Sapelo' or 'Zcluster'";
	}
	print SHL "echo You may proceed! >> flag$sub.txt";

}

foreach my $sub (@subs) {
while (not -e "flag$sub.txt") {sleep 5};
}
close(SRC);
system("echo 'Finished 02.makeblastdb.folder.pl!' >> job.monitor.txt");
system("chmod 777 -R 00.script");
system("chmod 777 -R 01.data/05.SplitGenes");

