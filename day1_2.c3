import std::io;

int[3] entry_max;

fn void update_max(int entry)
{
	for (int i = 0; i < 3; i++)
	{
		if (entry > entry_max[i])
		{
			for (int j = 2; j > i; j--)
			{
				entry_max[j] = entry_max[j - 1];
			}
			entry_max[i] = entry;
			return;
		}
	}
}

fn void main()
{
	File f = file::open("calories.txt", "rb")!!;
	defer (void)f.close();
	int current_entry = 0;
	while (!f.eof())
	{
		@pool()
		{
			String line = io::treadline(&f)!!;
			if (!line.len)
			{
				update_max(current_entry);
				current_entry = 0;
				continue;
			}
			current_entry += line.to_int()!!;
		};
	}
	if (current_entry) update_max(current_entry);
	int sum = 0;
	foreach (val : entry_max) sum += val;
	io::printfn("Top three elves carries: %d", sum);
}