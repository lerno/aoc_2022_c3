module day7;
import std::array::list;
import std::io;

define DirList = List<Directory*>;

struct Directory
{
	String name;
	DirList other_dirs;
	Directory* parent_dir;
	long own_files_size;
}

fn long Directory.total_size(Directory* this)
{
	long total = this.own_files_size;
	foreach (Directory* dir : this.other_dirs) total += dir.total_size();
	return total;
}

fn Directory *handle_command(String command, Directory* top, Directory* current_dir)
{
	if (command[2..] == "ls") return current_dir;
	assert(command[2..3] == "cd");
	String dir_name = command[5..];
	switch DIR: (dir_name)
	{
		case "/":
			return top;
		case "..":
			assert(current_dir.parent_dir);
			return current_dir.parent_dir;
		default:
			foreach (Directory* dir : current_dir.other_dirs)
			{
				if (dir.name == dir_name)
				{
					return dir;
				}
			}
			unreachable("Unknown dir");
	}
}

fn void parse_dir(Directory *top)
{
	File f;
	f.open("dir.txt", "rb")!!;
	defer catch(f.close());
	Directory* current_dir;
	while TOP: (!f.eof())
	{
		String line = f.tgetline();
		if (!line.len) break;
		if (line[0] == '$')
		{
			current_dir = handle_command(line, top, current_dir);
			continue;
		}
		if (line[0..2] == "dir")
		{
			Directory *new_dir = talloc(Directory);
			*new_dir = { .name = line[4..], .parent_dir = current_dir };
			current_dir.other_dirs.append(new_dir);
			continue;
		}
		String[] split = str::tsplit(line, " ");
		assert(split.len == 2);
		current_dir.own_files_size += str::to_long(split[0])!!;
	}
}

fn long count_dir_1(Directory *dir)
{
	long total = 0;
	foreach (Directory* child : dir.other_dirs)
	{
		total += count_dir_1(child);
	}
	long this_total = dir.total_size();
	if (this_total < 100000) total += this_total;
	return total;
}
fn void part1(Directory* top)
{
	io::printfn("Total size of small dirs: %d", count_dir_1(top));
}

fn bool part2_find(Directory* dir, long *smallest_found, long needed)
{
	long dir_size = dir.total_size();
	if (dir_size < needed) return false;
	bool found_child = false;
	foreach (Directory* child : dir.other_dirs)
	{
		if (part2_find(child, smallest_found, needed)) found_child = true;
	}
	if (found_child) return true;
	if (dir_size >= *smallest_found) return false;
	*smallest_found = dir_size;
	return true;
}

fn void part2(Directory* top)
{
	long used = top.total_size();
	long free = 70_000_000 - used;
	long need_to_free = 30_000_000 - free;
	assert(need_to_free > 0);
	long smallest_found = used + 1;
	part2_find(top, &smallest_found, need_to_free);
	io::printfn("Smallest dir size to remove: %s", smallest_found);
}
fn void main()
{
	Directory top = { .name = "/" };
	parse_dir(&top);
	part1(&top);
	part2(&top);
}