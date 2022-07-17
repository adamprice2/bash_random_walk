#!/bin/bash
random()
{
	local low high
	declare -i low high
	high="${1:-32767}"
	low="${2:-0}"
	printf "%d\n" $(( (RANDOM % (high - low +1 ) ) + low )) 
}
print_at()
{
	# behaves like echo. Outputs each arg separated by space.
	# to preserve formatting in strings pass them as a single argument.
	
	# X,Y = position # int
	declare -i x y

	# word = loop variable for words to print
	local word
	
	x="${1:? missing x coordinate}"
	shift
	y="${1:? missing y coordinate}"
	shift
	# save cursor
	tput sc
	# Note $y $x not $x $y as expected.
	tput cup "$y" "$x"

	for word in "${@}" ; do
		printf "%s " "${word}"
	done
	tput rc
}

setcolor()
{
	# foreground and background color # int
	declare -i foreground
	foreground="${1:? missing foreground}"


	tput setaf "$foreground"

}


display()
{
	inputfile="${1:-/dev/stdin}"
	colors="$(tput colors)"


	while IFS=" " read -r  sentence ; do
		for word in ${sentence} ; do

			# capture columns and lines inside the word loop to allow for screen resizing
			
			columns="(( $(tput cols) - 2))"
			lines="(( $(tput lines) -2 ))"
			fg="$(random "$colors")"
			x="$(random "$columns")"
			y="$(random "$lines")" 
			setcolor "${fg}"
			print_at "${x}" "${y}" "${word}"
		done
	done < "${inputfile}"
}


ctrl_c_handler()
{
	tput rmcup
	exit
}


main()
{
	# switch to alternate screen buffer
	tput smcup
	
	# If $1 is empty then display from stdin, else display first file
	
	file="${1:-/dev/stdin}"
	display "$file"
	# Then do the rest of the arguments, if there are none just exit
	shift
	
	for file in "${@}" ; do
		display "$file"
		sleep 0.4
	done

	# switch back to main screen buffer
	tput rmcup
}

trap ctrl_c_handler INT
main "${@}"

	

