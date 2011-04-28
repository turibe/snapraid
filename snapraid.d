Name{number}
	snapraid - SnapRAID Backup For Disk Arrays

Synopsis
	:snapraid [-c, --conf CONFIG] [-f, --filter PATTERN]
	:	[-Z, --force-zero] [-E, --force-empty]
	:	[-s, --start BLKSTART] [-t, --count BLKCOUNT]
	:	[-v, --verbose]
	:	COMMAND

	:snapraid [-V, --version] [-h, --help]

Description
	SnapRAID is a backup program for a disk array using redundancy.

	SnapRAID uses a disk of the array to store redundancy information,
	and it allows to recover from up to two disk failures.

	SnapRAID is mainly targeted for a home media center, where you have
	a lot of big files that rarely change.

	Beside the ability to recover from disk failures, the other
	features of SnapRAID are:

	* You can start using SnapRAID with already filled disks.
	* The disks can have different sizes.
	* You can add more disks at any time.
	* If you accidentally delete some files in a disk, you can
		recover them.
	* If more than two disk fails, you lose the data only on the
		failed disks. All the data in the other disks is safe.
	* It doesn't lock-in your data. You can stop using SnapRAID at any
		time without the need to reformat or move data.
	* All your data is hashed to ensure data integrity.

	The official site of SnapRAID is:

		:http://snapraid.sourceforge.net

Limitations
	SnapRAID is in between a RAID and a Backup program trying to get the best
	benefits of them. Although it also has some limitations that you should
	consider before using it.

	The main one, is that if a disk fail, and you haven't recently synced,
	you may not able to do a complete recover.
	More specifically, you may be unable to recover up to the size of the
	amount of the changed or deleted files, from the last sync operation.
	This happens even if the files changed or deleted are not in the
	failed disk.
	New added files don't prevent the recovering of the already existing
	files. You may only lose the just added files, if they were on the failed
	disk.

	This is the reason because SnapRAID is better suited for data that
	rarely change.

	Other limitations are:

	* You have different file-systems for each disk.
		Using a RAID you have only a big file-system.
	* It doesn't stripe data.
		With RAID you get a speed boost with striping.
	* It doesn't support real-time recovery.
		With RAID you do not have to stop working when a disk fails.
	* It's able to recover damages only from up to two disks.
		With a Backup you are able to recover from a complete
		failure of the whole disk array.
	* It identifies changes checking file time and size. If you have
		a program that arbitrarily restore the file time, such changes
		are not detected if the size doesn't change.
	* Only the file data is saved. Permissions, time, extended attributes,
		hard-links, symbolic-links are not saved.

Getting Started
	To use SnapRAID you need first select one disk of your disk array
	to dedicate at the "parity" information. With parity you will be able
	to recover from a single disk failure, like RAID5.

	If you want to recover from two disk failures, like RAID6, you must
	reserve another disk for the "q-parity" information.

	For the parity disks, you have to pick the biggest disks in the array,
	as the redundancy information may grow in size as the biggest data
	disk in the array.

	These disks will be dedicated to store the "parity" and "q-parity"
	files.
	You should not store other data on them, with the exception of
	a copy the "content" file, that contains the list of all the files
	stored in your array with all the checksums to verify their integrity.

	For example, suppose that you are interested only at one parity level
	of protection, and that your disks are present in:

		:/mnt/diskpar <- selected disk for parity
		:/mnt/disk1 <- first disk to backup
		:/mnt/disk2  <- second disk to backup
		:/mnt/disk3 <- third disk to backup

	you have to create the configuration file /etc/snapraid.conf with
	the following options:

		:parity /mnt/diskpar/parity
		:content /mnt/diskpar/content
		:disk d1 /mnt/disk1/
		:disk d2 /mnt/disk2/
		:disk d3 /mnt/disk3/

	If you are in Windows, you should use drive letters and backslash
	instead of slash:

		:parity E:\par\parity
		:content E:\par\content
		:disk d1 F:\array\
		:disk d2 G:\array\
		:disk d3 H:\array\

	At this point you are ready to start the "sync" command to build the
	redundancy information.

		:snapraid sync

	This process may take some hours the first time, depending on the size
	of the data already present in the disks. If the disks are empty
	the process is immediate.

	You can stop it at any time pressing Ctrl+C, and at the next run it
	will start where interrupted.

	When this command completes, your data is SAFE.

	At this point you can start using your array as you like, and periodically
	update the redundancy information running the "sync" command.

	To check the integrity of your data you can use the "check" command:

		:snapraid check

	If will read all your data, to check if it's correct.

	If an error is found, you can use the "fix" command to fix it.

		:snapraid fix

	Note that the fix command will revert your data at the state of the
	last "sync" command executed. It works like a snapshot was taken
	in "sync".

	In this regard snapraid is more like a backup program than a RAID
	system. For example, you can use it to recover from an accidentally
	deleted directory, simply running the fix command like.

		:snapraid fix -f JUST_DELETED_DIR/

Commands
	SnapRAID provides three simple commands that allow to:

	* Make a backup/snapshot -> "sync"
	* Check for integrity -> "check"
	* Restore the last backup/snapshot -> "fix".

	=sync
		Updates the redundancy information. All the modified files
		in the disk array are read, and the redundancy data is
		recomputed.
		Files are identified by inode and checked by time and size,
		meaning that you can move them on the disk without triggering
		any redundancy recomputation.
		You can stop this process at any time pressing Ctrl+C,
		without losing the work already done.
		The "content", "parity" and "q-parity" files are modified if necessary.
		The files in the array are NOT modified.

	=check
		Checks all the files and the redundancy data.
		All the files are hashed and compared with the snapshot saved
		in the previous "sync" command.
		Files are identified by path, and checked by content.
		Nothing is modified.

	=fix
		Checks and fix all the files. It's like "check" but it
		also tries to fix problems reverting the state of the
		disk array at the previous "sync" command.
		After a successful "fix", you should also run a "sync"
		command to update the new state of the files.
		The "content" file is NOT modified.
		The "parity" and "q-parity" files are modified if necessary.
		The files in the array are modified if necessary.

Options
	-c, --conf CONFIG
		Selects the configuration file. If not specified is assumed
		the file '/etc/snapraid.conf' in Unix, and 'snapraid.conf' 
		in Windows.

	-f, --filter PATTERN
		Filters the files to operate on with the "check" and "fix"
		commands. This option is ignored with the "sync" command.
		See the PATTERN section for more details in the
		pattern specifications.
		This option can be used many times.
		In Unix, ensure to quote globbing chars if used.

	-Z, --force-zero
		Forces the insecure operation of syncing a file with zero
		size that before was not empty.
		If SnapRAID detects such condition, it stops proceeding
		unless you specify this option.
		This allows to easily detect when after a system crash,
		some accessed files were zeroed.

	-E, --force-empty
		Forces the insecure operation of syncing an empty disk
		that before was not empty.
		If SnapRAID detects such condition, it stops proceeding
		unless you specify this option.
		This allows to easily detect when a data file-system is not
		mounted.

	-s, --start BLKSTART
		Starts the processing from the specified
		block number. It could be useful to easy retry to check
		or fix some specific block, in case of a damaged disk.

	-t, --count BLKCOUNT
		Process only the specified number of blocks.
		It's present mainly for advanced manual recovering.

	-v, --verbose
		Prints more information in the processing.

	-h, --help
		Prints a short help screen.

	-V, --version
		Prints the program version.

Configuration
	SnapRAID requires a configuration file to know where your disk array
	is located, and where storing the redundancy information.

	This configuration file is located in /etc/snapraid.conf in Unix or
	in the execution directory in Windows.

	It should contains the following options:

	=parity FILE
		Defines the file to use to store the parity information.
		The parity enables the protection from a single disk
		failure, like RAID5.
		It must be placed in a disk dedicated for this purpose with
		as much free space as the biggest disk in the array.
		Leaving the parity disk reserved for only this file ensures that
		it doesn't get fragmented, improving the performance.
		This option is mandatory and it can be used only one time.

	=q-parity FILE
		Defines the file to use to store the q-parity information.
		If present, the q-parity enables the protection from two disk
		failures, like RAID6.
		It must be placed in a disk dedicated for this purpose with
		as much free space as the biggest disk in the array.
		Leaving the q-parity disk reserved for only this file ensures that
		it doesn't get fragmented, improving the performance.
		This option is optional and it can be used only one time.

	=content FILE
		Defines the file to use to store the list and checksum of the
		content of your disk array.
		It can be placed in the same disk of the parity and q-aparity file,
		or better in another disk, but NOT in a data disk of the array.
		This option is mandatory and it can be used more time to save
		more copies of the same files.
		It's suggested to store at least one copy for each parity disk.
		One more doesn't hurt, just in case you lose all the parity disks,
		and you to be still able to check the data integrity.

	=disk NAME DIR
		Defines the name and the mount point of the disks of the array.
		NAME is used to identify the disk, and it must be unique.
		DIR is the mount point of the disk in the file-system.
		You can change the mount point as you like, as long you
		keep the NAME fixed.
		The specification order is also important, if you change it,
		you will invalidate the q-parity file.
		You should use one option for each disk of the array.

	=exclude PATTERN
	=include PATTERN
		Defines the file or directory patterns to exclude and include
		in the sync process.
		All the patterns are processed in the specified order, and
		we get the result of the first pattern that matches.
		If no pattern matches, the file is excluded if the last pattern
		is an "include", or included if the last pattern is an "exclude".
		See the PATTERN section for more details in the
		pattern specifications.
		This option can be used many times.

	=block_size SIZE_IN_KIBIBYTES
		Defines the basic block size in kibi bytes of
		the redundancy blocks. Where one kibi bytes is 1024 bytes.
		The default is 256 and it should work for most conditions.
		You could increase this value if you do not have enough RAM
		memory to run SnapRAID.
		SnapRAID requires about TS*24/BS bytes of RAM memory.
		Where TS is the total size in bytes of your disk array,
		and BS is the block size in bytes.

		For example with 6 disk of 2 TiB and a block size of 256 KiB
		(1 KiB = 1024 Bytes) you have:

		:RAM = (6 * 2 * 2^40) * 24 / (256 * 2^10) = 1.1 GiB

		You could instead decrease this value if you have a lot of
		small files in the disk array. For each file, even if of few
		bytes, a whole block is always allocated, so you may have a lot
		of unused space.
		As approximation, you can assume that half of the block size is
		wasted for each file.

		For example, with 10000 files and a 256 KiB block size, you are
		going to waste 1.2 GiB.

	An example of a typical configuration is:

		:parity /mnt/diskpar/parity
		:content /mnt/diskpar/content
		:content /var/snapraid/content
		:disk d1 /mnt/disk1/
		:disk d2 /mnt/disk2/
		:disk d3 /mnt/disk3/
		:exclude *.bak
		:exclude /lost+found/
		:exclude tmp/

Pattern
	Patterns are used to select a subset of files to exclude or include in
	the process.

	There are four different types of patterns:

	=FILE
		Selects any file named as FILE. You can use any globbing
		character like * and ?.
		This pattern is applied only to files and not to directories.

	=DIR/
		Selects any directory named DIR. You can use any globbing
		character like * and ?.
		This pattern is applied only to directories and not to files.

	=/PATH/FILE
		Selects the exact specified file path. You can use any
		globbing character like * and ? but they never matches a
		directory slash.
		This pattern is applied only to files and not to directories.

	=/PATH/DIR/
		Selects the exact specified directory path. You can use any
		globbing character like * and ? but they never matches a
		directory slash.
		This pattern is applied only to directories and not to files.

	Note that when globbing chars are used in the command line, you have to
	quote them in Unix. Otherwise the shell will try to expand them.

	In the configuration file, you can use different strategies to filter
	the files to process.
	The simplest one is to only use "exclude" rules to remove all the
	files and directories you do not want to process. For example:

		:# Excludes any file named "*.bak"
		:exclude *.bak
		:# Excludes the root directory "/lost+found"
		:exclude /lost+found/
		:# Excludes any sub-directory named "tmp"
		:exclude tmp/

	The opposite way is to define only the file you want to process, using
	only "include" rules. For example:

		:# Includes only some directories
		:include /movies/
		:include /musics/
		:include /pictures/

	The final way, is to mix "exclude" and "include" rules. In this case take
	care that the order of rules is important. Previous rules have the
	precedence over the later ones.
	To get things simpler you can first have all the "exclude" rules and then
	all the "include" ones. For example:

		:# Excludes any file named "*.bak"
		:exclude *.bak
		:# Excludes any sub-directory named "tmp"
		:exclude tmp/
		:# Includes only some directories
		:include /movies/
		:include /musics/
		:include /pictures/

	On the command line, using the -f option, you can only use "include"
	patterns. For example:

		:# Checks only the .mp3 files.
		:# Note the "" use to avoid globbing expansion by the shell in Unix.
		:snapraid -f "*.mp3" check

Content
	SnapRAID stores the list and checksums of your files in the content file.

	It's a text file, listing all the files present in your disk array,
	with all the checksums to verify their integrity.
	You do not need to understand its format, but it's described here
	for documentation.

	This file is read and written by the "sync" command, and only read by
	"fix" and "check".
	You should never change it manually, although the format of this file
	is described here.

	=blk_size SIZE
		Defines the size of the block in bytes. It must match the size
		defined in the configuration file.

	=file DISK SIZE TIME INODE PATH
		Defines a file in the specified DISK.
		The INODE number is used to identify the file in the "sync"
		command, allowing to rename or move the file in disk without
		the need to recompute the parity for it.
		The SIZE and TIME information are used to identify if the file
		changed from the last "sync" command, and if there is the need
		to recompute the parity.
		The PATH information is used in the "check" and "fix" commands
		to identify the file.

	=blk BLOCK HASH
		Defines the ordered parity block list used by the last defined file.
		BLOCK is the block position in the "parity" file.
		0 for the first block, 1 for the second one and so on.
		HASH is the hash of the block. In the last block of the file,
		the HASH is the hash of only the used part of the block.

	=inv BLOCK [HASH]
		Like "blk", but inform that the parity of this block is invalid.
		The HASH may be missing if not yet computed.
		This field is used only when you interrupt manually the "sync"
		command.

Parity
	SnapRAID stores the redundancy information of your array in the parity
	and q-parity files.

	They are binary files, containing the computed redundancy of all the
	blocks defined in the "content" file.
	You do not need to understand its format, but it's described here
	for documentation.

	These files are read and written by the "sync" and "fix" commands, and
	only read by "check".

	For all the blocks at a given position, the parity and the q-parity
	are computed as specified in:

		:http://kernel.org/pub/linux/kernel/people/hpa/raid6.pdf

	When a file block is shorter than the default block size, for example
	because it's the last block of a file, it's assumed as filled with 0
	at the end.

Copyright
	This file is Copyright (C) 2011 Andrea Mazzoleni

See Also
	rsync(1)
