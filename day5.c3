module day5;
import std::io;
import std::collections::list;

define CharList = list::List<char>;

const MAX_PILES = 20;

fn int init_piles(CharList[MAX_PILES]* piles, File* f)
{
	foreach (CharList* &list : piles) list.init();
	int piles_used = 0;
	while (!f.eof())
	{
		@pool()
		{
			String line = f.tgetline();
			if (!line.len) return piles_used;
			int piles_found = (line.len + 1) / 4;
			assert(piles_found < MAX_PILES && piles_found > 0);
			if (piles_found > piles_used) piles_used = piles_found;
			for (int i = 0; i < piles_found; i++)
			{
				char c = line[i * 4 + 1];
				if (c == ' ') continue;
				if (c == i + '1') continue;
				assert(c >= 'A' && c <= 'Z');
				(*piles)[i].push_front(c);
			}
		};
	}
	unreachable("Illegal format");
}

macro void @process_moves(; @body(int move_amount, CharList* a, CharList *b))
{
	File f;
	f.open("crates.txt", "rb")!!;
	defer (void)f.close();

	CharList[MAX_PILES] piles;
	int piles_used = init_piles(&piles, &f);
	while (!f.eof())
	{
		@pool()
		{
			String line = f.tgetline();
			String[] command = str::split(line, " ");
			assert(command.len == 6);
			int move_amount = str::to_int(command[1])!!;
			int from = str::to_int(command[3])!!;
			int to = str::to_int(command[5])!!;
			assert(from <= piles_used && to <= piles_used && from > 0 && to > 0);
			CharList* from_list = &piles[from - 1];
            CharList* to_list = &piles[to - 1];
			@body(move_amount, from_list, to_list);
		};
	}
	for (int i = 0; i < piles_used; i++)
	{
		io::printf("%c", *piles[i].last());
	}
	io::println();
}


fn void part1()
{
	@process_moves(;int moves, CharList* from, CharList* to)
	{
        for (int i = 0; i < moves; i++)
		{
			char c = from.pop();
			to.push(c);
		}
	};
}

fn void part2()
{
	@process_moves(;int moves, CharList* from, CharList* to)
	{
		for (int i = moves; i > 0; i--)
		{
			to.push((*from)[^i]);
		}
		for (int i = 0; i < moves; i++) from.pop();
	};

}


fn void main()
{
	part1();
	part2();
}