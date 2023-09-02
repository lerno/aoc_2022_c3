import std::io;
import libc;

fn void main()
{
	File f = file::open("calories.txt", "rb")!!;
	defer (void)f.close();
	usz current_entry = 0;
	usz max_entry = 0;
	usz max_elf = 1;
	usz index_elf = 1;
	while (!f.eof())
	{
		@pool()
		{
			String line = f.treadline();
			if (!line.len)
			{
				current_entry = 0;
				index_elf++;
				continue;
			}
			current_entry += line.to_int()!!;
			if (current_entry > max_entry)
			{
				max_elf = index_elf;
				max_entry = current_entry;
			}
		};
	}
	io::printfn("Elf #%d carries the most calories (%d)", max_elf, max_entry);
}
