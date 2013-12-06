# -*-Perl-*- Test Harness script for Bioperl
# $Id$

use strict;

BEGIN { 
    use lib '.';
    use Bio::Root::Test;
    
    test_begin(
        -tests => 42,
        -requires_modules => [qw(URI::Escape Graph::Directed)],
        -requires_networking => 1
    );

    use_ok('Bio::SeqFeature::Annotated');
}

my ($sfa, $sfa2, $sfa3, $loc, $sfg, $sfaa);

ok $sfa = Bio::SeqFeature::Annotated->new(
    -start => 1,
    -end => 5,
    -strand => '+',
    -frame => 2,
    -type => 'nucleotide_motif',
    -phase => 2,
    -score => 12,
    -source => 'program_b',
    -display_name => 'test.annot',
    -seq_id => 'test.displayname',
);

isa_ok($sfa, "Bio::SeqFeatureI",'isa SeqFeatureI');
isa_ok($sfa, "Bio::AnnotatableI",'isa AnnotatableI');

ok $loc = $sfa->location;
ok $loc->isa('Bio::Location::Simple');
ok $sfa->display_name eq 'test.annot';
ok $sfa->gff_string;

# Test bsfa::from_feature
$sfg = Bio::SeqFeature::Generic->new (
    -start => 400,
    -end => 440,
    -strand => 1,
    -primary => 'nucleotide_motif',
    -source  => 'program_a',
    -tag => {
        silly => 20,
        new => 1
    }
);

ok $sfa2 = Bio::SeqFeature::Annotated->new(-feature => $sfg);

is $sfa2->type->name,'nucleotide_motif';
is $sfa2->primary_tag, 'nucleotide_motif';
is $sfa2->source->display_text,'program_a';
is $sfa2->source_tag,'program_a';
is $sfa2->strand,1;
is $sfa2->start,400;
is $sfa2->end,440;
is $sfa2->get_Annotations('silly')->value,20;
is $sfa2->get_Annotations('new')->value,1;

ok $sfaa = Bio::SeqFeature::Annotated->new(-feature => $sfa);
is $sfaa->type->name,'nucleotide_motif';
is $sfaa->primary_tag, 'nucleotide_motif';
is $sfaa->source->display_text,'program_b';
is $sfaa->source_tag,'program_b';
is $sfaa->strand,1;
is $sfaa->start,1;
is $sfaa->end,5;
is $sfaa->score,12;

ok $sfa3 = Bio::SeqFeature::Annotated->new(
    -start => 1,
    -end => 5,
    -strand => '+',
    -frame => 2,
    -phase => 2,
    -score => 12,
    -display_name => 'test.annot',
    -seq_id => 'test.displayname',
);

ok $sfa3->from_feature($sfg);
is $sfa3->type->name,'nucleotide_motif', 'type->name';
is $sfa3->primary_tag, 'nucleotide_motif', 'primary_tag';
is $sfa3->source->display_text,'program_a';
is $sfa3->source_tag,'program_a';
is $sfa3->strand,1;
is $sfa3->start,400;
is $sfa3->end,440;
is $sfa3->get_Annotations('silly')->value,20;
is $sfa3->get_Annotations('new')->value,1;

# Note there is an API conflict with SeqFeature::Generic, where score is a
# simple scalar, and here it is a Bio::Annotation::SimpleValue
# By popular vote there is no operator overloading, so this needs to be
# resolved

is $sfa3->score(), 12;
ok $sfa3->score(11);
is $sfa3->score(), 11; 
$sfa3->score(0);
is $sfa3->score(), 0;	# test that setting to 0 no longer is overriddent to set score to '.' (fixed in Bio::SeqFeature::Annotated version 1.3.7)

done_testing();

exit;
