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
	File f;
	f.open("calories.txt", "rb")!!;
	defer (void)f.close();
	int current_entry = 0;
	while (!f.eof())
	{
		@pool()
		{
			String line = f.tgetline();
			if (!line.len)
			{
				update_max(current_entry);
				current_entry = 0;
				continue;
			}
			current_entry += str::to_int(line)!!;
		};
	}
	if (current_entry) update_max(current_entry);
	int sum = 0;
	foreach (val : entry_max) sum += val;
	io::printfn("Top three elves carries: %d", sum);
}
