#!/usr/bin/perl
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
        (/(.*),(.*)/) ? ($keyword_hash{$1} = $2) : print "ERROR: unkonwn keyword exists,check gen_format.cfg";
        #print "$1=>$2 ";
    }
    while(<INPUT1>){
        #注释过滤部分
        /(.*?)\/\// && ($_ = $1);
	if (/\/\*/){
	    while(!/\*\//){
	        $_ = <INPUT1>;	
	    }
	    $_ = <INPUT1>;
	}
	#过滤结束
	foreach $key(keys %keyword_hash){
            if(/$key/){
                #print "1--",$_;
                push @line_num_list,$.;
                push @keyword_list,$&;
                last;
            }
            if(/$keyword_hash{$key}/){
                #print "2--",$_;
                if(@line_num_list == 0){
                    print "ERROR:end keyword is single,line $. lose its couple\n";
                    exit 1;
                }
                else{
                    $line_num = pop @line_num_list;
		    $keyword = pop @keyword_list;
                    if($& =~ /$keyword_hash{$keyword}/){
                        $couple_hash{$line_num} = $.;
                        last;                        
                    }
                    else{
		        print "ERROR:keywords do not match,see line $line_num($keyword) and line $.($&) \n";
                        exit 1;
                    }
                }
            }
        }
    }
    if(@line_num_list > 0){
        print "ERROR:start keyword is single,line ",pop @line_num_list," lose its couple\n";
        exit 1;
    }
    while(<INPUT2>){
        $_ =~ s/\s*(.*)/$1/ if(!/^\s*$/);
        foreach $k(keys %couple_hash){
            $_ = $mark.$_ if(($. > $k) and ($. < $couple_hash{$k}))
        }
        printf OUTPUT $_;
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
