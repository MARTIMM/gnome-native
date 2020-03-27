use v6;

my %options = %(
  :o1<option1>,
  :o2<option2>,
  :o3<option3>,
  :o4<option4>,
);

for %options.keys {
  when 'o1' {
    say %options{$_};
  }
  when 'o2' {
    say 'option2';
  }
  when 'o3' {
    say 'option3';
  }
  when 'o4' {
    say 'option4';
  }
}
