#!/usr/bin/perl -w
#running command: time perl 00.script/03.diamond.folder.pl 01.data/02.Fasta 01.data/05.SplitGenes/01.Protein/run.0 03.blast/03.bowtie.nucl/run.0 nucl bowtie.log/bowtie.run.0 paired-end Sapelo

use strict;
system("echo 'Running 03.diamond.folder.pl ....' >> job.monitor.txt");

## read in parameters required by the script
my $qryfolder = shift @ARGV;
my $dbfolder = shift @ARGV;
my $tgtfolder = shift @ARGV;
my $seqtype = shift @ARGV;
my $logfolder = shift @ARGV;
my $evalue = shift @ARGV;
my $mode = shift @ARGV;
my $platform = lc(shift @ARGV);
my ($run) = $tgtfolder =~ /run\.([0-9]+)/;
my $thread = 4;

## start running the script
opendir(QRY, $qryfolder) or die "ERROR: Cannot open $qryfolder: $!";
my @subs = sort(grep(/^\w.+/, readdir(QRY)));

opendir(DBF, $dbfolder) or die "ERROR: Cannot open $dbfolder: $!";
my @dbs = sort(grep(/^[0-9]+/, readdir(DBF)));
@dbs = @dbs;

system("rm -rf 00.script/$logfolder");
system("mkdir -p 00.script/$logfolder");

foreach my $db (@dbs){		## loop over referece groups
	foreach my $sub (@subs){	## loop over samples
		my $shell = "00.script/$logfolder/bowtie.$seqtype.$db.$sub.sh";
		open(SHL, ">$shell") or die "ERROR: Cannot write $shell: $!";
		if($platform eq "sapelo"){
			print SHL "#PBS -S /bin/bash\n";
			print SHL "#PBS -q batch\n";
			print SHL "#PBS -N bowtie.$seqtype.$db.$sub.sh\n";
			print SHL "#PBS -l nodes=1:ppn=$thread:AMD\n";
			print SHL "#PBS -l walltime=48:00:00\n";
			print SHL "#PBS -l mem=30gb\n";
			print SHL "\n";
			print SHL "cd \$PBS_O_WORKDIR\n";
		}elsif($platform eq "zcluster"){
			print SHL "#!/bin/bash\n";
			$thread = 2;
		}else{
			die "Please provide the platform: 'Sapelo' or 'Zcluster'";
		}
	    my $command2 = 0;
		if($platform eq "sapelo"){
			$command2 = "/usr/local/apps/diamond/0.7.9/bin";
	    	print SHL "module load anaconda/2.2.0  boost/gcc447/1.57.0 zlib/gcc447/1.2.8\n";
			print SHL "mkdir -p $tgtfolder/$db\n";
			if($mode eq "paired-end" and $sub =~ /F$|Fu$|R$/){
				print SHL "time $command2/diamond blastx -p $thread -k 1 -e $evalue -d $dbfolder/$db/$db -q $qryfolder/$sub/$sub.simple.fasta -a $tgtfolder/$db/bowtie.out.$db.$sub\n";
				print SHL "$command2/diamond view -a $tgtfolder/$db/bowtie.out.$db.$sub.daa -o $tgtfolder/$db/bowtie.out.$db.$sub.tab -f tab\n";
				print SHL "rm -f $tgtfolder/$db/bowtie.out.$db.$sub.daa\n";
			}elsif($mode eq "paired-end"){
				print SHL "time $command2/diamond blastx -p $thread -k 1 -e $evalue -d $dbfolder/$db/$db -q $qryfolder/$sub/$sub.R1.fasta_simple.fasta -a $tgtfolder/$db/bowtie.out.$db.$sub.R1\n";
				print SHL "$command2/diamond view -a $tgtfolder/$db/bowtie.out.$db.$sub.R1.daa -o $tgtfolder/$db/bowtie.out.$db.$sub.R1.tab -f tab\n";
				print SHL "rm -f $tgtfolder/$db/bowtie.out.$db.$sub.R1.daa\n";
					
				print SHL "time $command2/diamond blastx -p $thread -k 1 -e $evalue -d $dbfolder/$db/$db -q $qryfolder/$sub/$sub.R2.fasta_simple.fasta -a $tgtfolder/$db/bowtie.out.$db.$sub.R2\n";
				print SHL "$command2/diamond view -a $tgtfolder/$db/bowtie.out.$db.$sub.R2.daa -o $tgtfolder/$db/bowtie.out.$db.$sub.R2.tab -f tab\n";
				print SHL "rm -f $tgtfolder/$db/bowtie.out.$db.$sub.R2.daa\n";
				
				if(-s "$qryfolder/$sub/$sub.singles.fasta_simple.fasta"){
					print SHL "time $command2/diamond blastx -p $thread -k 1 -e $evalue -d $dbfolder/$db/$db -q $qryfolder/$sub/$sub.singles.fasta_simple.fasta -a $tgtfolder/$db/bowtie.out.$db.$sub.single\n";
					print SHL "$command2/diamond view -a $tgtfolder/$db/bowtie.out.$db.$sub.single.daa -o $tgtfolder/$db/bowtie.out.$db.$sub.single.tab -f tab\n";
					print SHL "rm -f $tgtfolder/$db/bowtie.out.$db.$sub.single.daa\n";
				}else{
					print SHL ":> $tgtfolder/$db/bowtie.out.$db.$sub.single.tab\n";
				}
			}elsif($mode eq "single-end"){
				print SHL "time $command2/diamond blastx -p $thread -k 1 -e $evalue -d $dbfolder/$db/$db -q $qryfolder/$sub/$sub.simple.fasta -a $tgtfolder/$db/bowtie.out.$db.$sub\n";
				print SHL "$command2/diamond view -a $tgtfolder/$db/bowtie.out.$db.$sub.daa -o $tgtfolder/$db/bowtie.out.$db.$sub.tab -f tab\n";
				print SHL "rm -f $tgtfolder/$db/bowtie.out.$db.$sub.daa\n";
			}else{
				die "Error: Please specify the mode as 'single-end' or 'paired-end'.";
			}
	    }elsif($platform eq "zcluster"){
			$command2 = "/usr/local/diamond/0.6.12/bin";
			print SHL "mkdir -p $tgtfolder/$db\n";
			if($mode eq "paired-end"){
				print SHL "time $command2/diamond blastx -p $thread -k 1 -e $evalue -d $dbfolder/$db/$db -q $qryfolder/$sub/$sub.R1.fasta_simple.fasta -o $tgtfolder/$db/bowtie.out.$db.$sub.R1.tab\n";
				print SHL "time $command2/diamond blastx -p $thread -k 1 -e $evalue -d $dbfolder/$db/$db -q $qryfolder/$sub/$sub.R2.fasta_simple.fasta -o $tgtfolder/$db/bowtie.out.$db.$sub.R2.tab\n";
				if(-s "$qryfolder/$sub/$sub.singles.fasta_simple.fasta"){
					print SHL "time $command2/diamond blastx -p $thread -k 1 -e $evalue -d $dbfolder/$db/$db -q $qryfolder/$sub/$sub.singles.fasta_simple.fasta -o $tgtfolder/$db/bowtie.out.$db.$sub.single.tab\n";
				}else{
					print SHL ":> $tgtfolder/$db/bowtie.out.$db.$sub.single.tab\n";
				}
			}elsif($mode eq "single-end"){
				print SHL "time $command2/diamond blastx -p $thread -k 1 -e $evalue -d $dbfolder/$db/$db -q $qryfolder/$sub/$sub.simple.fasta -o $tgtfolder/$db/bowtie.out.$db.$sub.tab\n";
			}else{
				die "Error: Please specify the mode as 'single-end' or 'paired-end'.";
			}
		}else{
			die "Please provide the platform: 'Sapelo' or 'Zcluster'";
		}

		print SHL "touch 00.script/$logfolder/$db.$sub.done.log\n";
		close(SHL);
		system("chmod u+x $shell");
		if($platform eq "sapelo"){
	    	system("qsub $shell");
		}elsif($platform eq "zcluster"){
			system("qsub -q rcc-30d -pe thread $thread $shell");
		}else{
			die "Please provide the platform: 'Sapelo' or 'Zcluster'";
		}
	}
	
}
close(QRY);
close(DBF);
system("echo 'Finished 03.diamond.folder.pl!' >> job.monitor.txt");

system("chmod 777 -R 00.script/$logfolder");