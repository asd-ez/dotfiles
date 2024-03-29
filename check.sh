#! /bin/bash

# Stop if empty variable
set -u
# Stop on error
set -e

print_usage() {
	printf "Usage: ...nothing...\n"
}

while getopts :hf:c: OPTION; do
	case "${OPTION}" in
	f)
		type_commit="feat"
		message="${OPTARG}"
		;;
	c)
		type_commit="chore"
		message="${OPTARG}"
		;;
	h | *)
		print_usage
		exit 1
		;;
	esac
done

if [ -z "${type_commit}" ]; then
	print_usage
	exit 1
fi

replaced_message=$(echo "$message" | sed -r 's/[ .]+/_/g')
current_date=$(date +"%Y-%m-%d")
branch_name="$type_commit/$replaced_message-$current_date"
commit_message="$type_commit: $message $current_date"

git checkout -b "$branch_name"
git add .
git commit -m "$commit_message"
git push origin "$branch_name"

gh pr create \
	--label enhancement \
	--assignee @me \
	--body '' \
	--title "$commit_message" \
	--base master \
	--head "$branch_name"
gh pr merge --squash --delete-branch
