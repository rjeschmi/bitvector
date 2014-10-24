package chr_vector_worker;

# $neg_vector
# $pos_vector
# $chr_map_hash

sub {
    my ($pos_strand_vector, $neg_strand_vector, $chr_map_vector) = @_;
    my @total_mdr_count=0;$total_mdr_count[$vlen]=0;
    my @total_fgmdr_count=0;$total_fgmdr_count[$vlen]=0;
    my @total_pos_mdr=0;$total_pos_mdr[$vlen]=0;
    my @total_neg_mdr=0;$total_neg_mdr[$vlen]=0;
 
    if($verbose){ 
          print "Processing reads for: $chr\n";
    }
    #check for chromsomes with no reads, remove them from
    #the calculation
    if($pos_strand_vector->Norm()==0 && $pos_strand_vector->Norm()==0){
        if($verbose){
            print "Skipping calculations for $chr: no mapped reads found\n";
        }
        next;
    }
    my $Mdr = $pos_strand_vector->Shadow();
    my $working_vector2 = $Mdr->Shadow();
    my $working_vector3 = $Mdr->Shadow();
    my $working_vector4 = $Mdr->Shadow();
    my $neg_map_vector = $chr_map_vector;
    my $pos_map_vector = $neg_map_vector->Clone();
 
    #shift the end of the read to the start for MaSC
    for(my $i=0;$i<$read_len;$i++){
        $neg_map_vector->rotate_left();
    }
 
    my $neg_vector = $neg_strand_vector;
    my $pos_vector = $pos_strand_vector;
 
    $total_neg_reads+=${$neg_vector}->Norm();
    $total_pos_reads+=${$pos_vector}->Norm();
 
    for(my $i=0;$i<$min_shift;$i++){
        #rotate vector
        ${$neg_vector}->rotate_right();
        $neg_map_vector->rotate_right();
    }
 
    for(my $d=0;$d<=($max_shift-$min_shift);$d++){
        #neg_pos map overlap
        $working_vector2->And($neg_map_vector,$pos_map_vector);
        $total_mdr_count[$d] += $working_vector2->Norm();
        
        #neg pos strand overlap
        $working_vector3->And(${$neg_vector},${$pos_vector});
        $r1[$d] += $working_vector3->Norm();
 
        #strand and map overlap
        $working_vector4->And($working_vector3,$working_vector2);    
        $total_fgmdr_count[$d] += $working_vector4->Norm();
 
        #neg strand mdr
        $working_vector4->And(${$neg_vector},$working_vector2);
        $total_neg_mdr[$d] += $working_vector4->Norm();
            
        #pos strand mdr
        $working_vector4->And(${$pos_vector},$working_vector2);
        $total_pos_mdr[$d] += $working_vector4->Norm();
    
        #rotate vector
        ${$neg_vector}->rotate_right();
        $neg_map_vector->rotate_right();
    }

    return \$total_mdr_count, \$total_fgmdr_count, \$total_neg_mdr, 
}
