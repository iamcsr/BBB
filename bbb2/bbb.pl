#!/usr/bin/perl -w

use strict;

use Gtk2 -init;
use Glib qw(TRUE FALSE);

#use Filesys::Df;
#use File::Rsync;

#use Sys::Filesystem;

####Customizable Variables
my $source_mount = '/mnt/source';

my $welcome = Gtk2::Window->new('toplevel');
$welcome->signal_connect( delete_event => sub { Gtk2->main_quit } );
 
#Set-up the welcome window
$welcome->add( &firstTable() );
#$welcome->show();

my $niWin = &niWin;

#$niWin->show_all();

my @mfs = &getMntDr;

my $lwin = &testList;
$lwin->show_all();

Gtk2->main;

sub firstTable {

	#Make the table
	#widget = Gtk2::Table ->new ($rows, $columns, $homogeneous=FALSE)
	my $table = Gtk2::Table->new( 2, 2, FALSE );

#$table->attach_defaults ($widget, $left_attach, $right_attach, $top_attach, $bottom_attach)

	#The Label
	my $label =
	  Gtk2::Label->new("Welcome to BetterBartBackup!\nClick Yes to proceed");
	$table->attach_defaults( $label, 0, 2, 0, 1 );

	#Yes Button!
	my $yes = Gtk2::Button->new_from_stock("gtk-yes");
	$yes->signal_connect( 'clicked' => sub { } );
	$table->attach_defaults( $yes, 0, 1, 1, 2 );

	#No Button!
	my $no = Gtk2::Button->new_from_stock("gtk-no");
	$no->signal_connect( clicked => sub { Gtk2->main_quit } );
	$table->attach_defaults( $no, 1, 2, 1, 2 );

	$table->show_all();
	return $table;
}

sub niWin {

	my $dialog = Gtk2::Dialog->new(
		'Client ID Entry', undef, [qw/modal destroy-with-parent/],
		'gtk-cancel' => 'reject',
		'gtk-ok'     => 'accept'
	);

	my $niFrame = new Gtk2::Frame->new("Enter client's NetID: ");
	$niFrame->add( my $niEntry = new Gtk2::Entry->new() );
	$dialog->get_content_area()->add($niFrame);

	#	my $niVbox = Gtk2::VBox->new (0, 1);
	#	$niFrame->add()

	return $dialog;

}

sub getMntDr {
	my $fs = Sys::Filesystem->new();
	my @rfiles;
	my @filesystems = $fs->filesystems();

	#	my $i           = 0;
	for (@filesystems) {
		if (
			( $fs->device($_) =~ m%^/dev% )
			&& (   ( $fs->mount_point($_) ne '/' )
				&& ( $fs->mount_point($_) ne '/boot' ) )
		  )
		{
			printf( "%s is a %s filesystem mounted on %s\n",
				$fs->mount_point($_), $fs->format($_), $fs->device($_) );

			#			my %fst;
			#			$fst{'mp'}     = $fs->mount_point($_);
			#			$fst{'format'} = $fs->format($_);
			#			$fst{'dev'}    = $fs->device($_);
			#			$rfiles[$i]    = %fst;
			#			$i++;
			push @rfiles,
			  {
				'mp'   => $fs->mount_point($_),
				format => $fs->format($_),
				dev    => $fs->device($_)
			  };

		}
	}

	#	for my $i (0 .. $#rfiles) {
	#		print $i;
	#		print $rfiles[$i]{'mp'};
	#		print "\n";
	#	}
	return @rfiles;
}

sub testList {
	my $win = Gtk2::Window->new('toplevel');
	$win->signal_connect( delete_event => sub { Gtk2->main_quit } );

	my $sw = Gtk2::ScrolledWindow->new( undef, undef );
	$sw->set_shadow_type('etched-out');
	$sw->set_policy( 'automatic', 'automatic' );

	#This is a method of the Gtk2::Widget class,it will force a minimum
	#size on the widget. Handy to give intitial size to a
	#Gtk2::ScrolledWindow class object
	$sw->set_size_request( 350, 300 );

	#method of Gtk2::Container
	$sw->set_border_width(5);
	my $ls =
	  Gtk2::ListStore->new( qw/Glib::String/, qw/Glib::String/,
		qw/Glib::String/ );
	for my $i (0 .. $#mfs){
		my $itr = $ls->append();
		$ls->set($itr,0,$mfs[$i]{'mp'});
		$ls->set($itr,1,$mfs[$i]{'format'});
		$ls->set($itr,2,$mfs[$i]{'dev'});
		print $mfs[$i]{'mp'};
	}
	my $tr_view = Gtk2::TreeView->new($ls);
	my $tree_column = Gtk2::TreeViewColumn->new();
	my $tree_column2 = Gtk2::TreeViewColumn->new();
	my $tree_column3 = Gtk2::TreeViewColumn->new();
	$tree_column->set_title ("Mount Point");
	my $mren = Gtk2::CellRendererText->new;
	$tree_column->pack_start ($mren, FALSE);
	$tree_column->add_attribute($mren, text => 0);
	$tree_column2->set_title ("Format");
	my $fren = Gtk2::CellRendererText->new;
	$tree_column2->pack_start ($fren, FALSE);
	$tree_column2->add_attribute($fren, text => 1);
	my $dren = Gtk2::CellRendererText->new;
	$tree_column3->set_title ("Device");
	$tree_column3->pack_start ($dren, FALSE);
	$tree_column3->add_attribute($dren, text => 2);
	$tr_view->append_column ($tree_column);
	$tr_view->append_column ($tree_column2);
	$tr_view->append_column ($tree_column3);

	$sw->add($tr_view);
	$sw->show_all();
	$win->add($sw);
	return $win;
}
