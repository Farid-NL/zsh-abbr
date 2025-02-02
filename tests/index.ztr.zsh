#!/usr/bin/env zsh

# Tests require ztr
# https://github.com/olets/zsh-test-runner

# Run the test suite by
# sourcing this file
#
# ```
# . <path to this file>
# ```
#
# or by running it in a subshell with ZTR_PATH passed in as ztr_path
#
# ```
# ztr_path=$ZTR_PATH zsh <path to this file>
# ```

main() {
	emulate -LR zsh

	if [[ ${(%):-%#} == '#' ]]; then
		typeset -g ABBR_TEST_TMPDIR=${${TMPDIR:-/tmp}%/}/zsh-abbr-privileged-users-tests
	else
		typeset -g ABBR_TEST_TMPDIR=${${TMPDIR:-/tmp}%/}/zsh-abbr-tests
	fi
	
	local \
		abbr_dir \
		abbr_tmpdir_saved \
		abbr_user_abbreviations_file_saved \
		cmd \
		test_abbr_abbreviation \
		test_abbr_abbreviation_2 \
		test_abbr_abbreviation_multiword \
		test_abbr_abbreviation_multiword_2 \
		test_abbr_expansion \
		test_abbr_expansion_2 \
		test_dir \
		test_prefix

	local -a abbr_prefixes_saved
	
	local -i abbr_quiet_saved

	ztr_path=${ztr_path:-$ZTR_PATH}

	if [[ -z $ztr_path ]]; then
		printf "You must provide \$ztr_path\n"
		return 1
	fi

	cmd=$1

	abbr_dir=${0:A:h}
	if [[ $abbr_dir =~ "/tests" ]]; then
		abbr_dir+=/..
	fi

	test_dir=$abbr_dir/tests

	# Save user configuration
	abbr_quiet_saved=$ABBR_QUIET
	abbr_tmpdir_saved=$ABBR_TMPDIR
	abbr_user_abbreviations_file_saved=$ABBR_USER_ABBREVIATIONS_FILE

	# Configure
	ABBR_QUIET=1
	ABBR_USER_ABBREVIATIONS_FILE=$test_dir/abbreviations.$RANDOM.tmp
	ABBR_TMPDIR=$ABBR_TEST_TMPDIR

	# Set up data
	touch $ABBR_USER_ABBREVIATIONS_FILE
	test_abbr_abbreviation="zsh_abbr_test"
	test_abbr_abbreviation_2="zsh_abbr_test_2"
	test_abbr_abbreviation_multiword="zsh_abbr_test second_word"
	test_abbr_abbreviation_multiword_2="zsh_abbr_test other_second_word"
	test_abbr_expansion="zsh abbr test"
	test_abbr_expansion_2="zsh abbr test 2"

	# Source dependencies
	. $abbr_dir/zsh-abbr.zsh
	. $ztr_path

	# Clear zsh-test-runner summary
	ztr clear-summary

	# Run tests
	if [[ -n $cmd ]]; then
		. $test_dir/abbr-$cmd.ztr.zsh
	else
		for f ($test_dir/abbr-*.ztr.zsh(N.)); do
			printf "\nFile: %s\n\n" $f
			. $f
		done
	fi

	# Remove artifacts
	rm -f $ABBR_USER_ABBREVIATIONS_FILE

	# Reset
	ABBR_QUIET=$abbr_quiet_saved
	ABBR_TMPDIR=$abbr_tmpdir_saved
	ABBR_USER_ABBREVIATIONS_FILE=$abbr_user_abbreviations_file_saved
	if $(command -v _abbr_load_user_abbreviations); then
		_abbr_load_user_abbreviations
	fi

	# Print test suite results
	echo
	ztr summary
}

main $@
