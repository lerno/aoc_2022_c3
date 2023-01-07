import std::io;
import libc;

fn void main()
{
	File f;
	f.open("calories.txt", "rb")!!;
	defer catch(f.close());
	usz current_entry = 0;
	usz max_entry = 0;
	usz max_elf = 1;
	usz index_elf = 1;
	while (!f.eof())
	{
		@pool()
		{
			String line = f.tgetline();
			if (!line.len)
			{
				current_entry = 0;
				index_elf++;
				continue;
			}
			current_entry += str::to_int(line)!!;
			if (current_entry > max_entry)
			{
				max_elf = index_elf;
				max_entry = current_entry;
			}
		};
	}
	io::printfln("Elf #%d carries the most calories (%d)", max_elf, max_entry);
}
