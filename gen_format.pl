#!/usr/bin/perl -w
$mark = " "x4;
if(@ARGV == 2){
    $cfg_log = $ARGV[0];
    $input = $ARGV[1];
    $output = $input."_format";
    open CFG_LOG, "< $cfg_log" or die "can not open $cfg_log";
    open INPUT1, "< $input" or die "can not open $input";
    open INPUT2, "< $input" or die "can not open $input";
    open OUTPUT, "> $output" or die "can not open $output";
    while(<CFG_LOG>){
        /(.*),(.*)/ ? ($keyword_hash{$1} = $2) : die "ERROR: unkonwn keyword exists,check gen_format.cfg";
        #print "$1=>$2\n";
    }
    while(<INPUT1>){
        &filter;
	foreach $key(keys %keyword_hash){
            if(/$key/){
                #print "1--",$_;
                push @line_num_list,$.;
                push @keyword_list,$key;
                last;
            }
            if(/$keyword_hash{$key}/){
                #print "2--",$_;
                if(@line_num_list == 0){
                    die "ERROR:end keyword is single,line $. lose its couple\n";
                }
                else{
                    $line_num = pop @line_num_list;
		            $keyword = pop @keyword_list;
                    if($key eq $keyword){
                        $couple_hash{$line_num} = $.;
                        last;                        
                    }
                    else{
		        die "ERROR:keywords do not match,see line $line_num($keyword) and line $.($keyword_hash{$key}) \n";
                    }
                }
            }
        }
    }
    (@line_num_list > 0) && die "ERROR:start keyword is single,line ",pop @line_num_list," lose its couple\n";
    while(<INPUT2>){
        $_ =~ s/\s*(.*)/$1/ if(!/^\s*$/);
        foreach $k(keys %couple_hash){
            $_ = $mark.$_ if(($. > $k) and ($. < $couple_hash{$k}))
        }
        print OUTPUT $_;
    }
    close CFG_LOG;
    close INPUT1;
    close INPUT2;
    close OUTPUT;
    print "Job Done!\nThe tmp file will overwrite the original file if you type Y\nType in your choice [Y/N] :";
    system("gvim $output");
    chomp ($choice = <STDIN>);
    if($choice eq "Y"){
        system("rm -rf $input");
	system("mv -f $output $input");
    }
}
else {
    print "ERROR!"
}
sub filter{
    /(.*?)\/\// && ($_ = $1);
    if (/\/\*/){
        while(!/\*\//){
	    $_ = <INPUT1>;
	}
	$_ = <INPUT1>;
    }
}
