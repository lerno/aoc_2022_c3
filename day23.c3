module day23;
import std::io;
import std::math;
import std::array::list;

define CharsArray = List<char[]>;

// Pick a padding that doesn't hit the asserts.
const int PADDING = 100;

fn void print_map(CharsArray* list)
{
	io::println("-----");
	foreach (char[] line : list)
	{
		io::println(line);
	}
	io::println("-----");
}

fn void load_map(CharsArray* list)
{
	File f;
	f.open("crater.txt", "rb")!!;
	defer catch(f.close());
	isz width;
	char[PADDING] spacing;
	spacing[..] = '.';
	while (!f.eof())
	{
		@pool()
		{
			char[] line = f.tgetline();
			width = line.len;
			line = str::tconcat(&spacing, line);
			list.append(str::copy(str::tconcat(line, &spacing)));
		};
	}
	char[] top_line = array::alloc(char, width + PADDING * 2);
	top_line[..] = '.';
	for (int i = 0; i < PADDING; i++)
	{
		list.insert_at(0, str::copy(top_line));
		list.append(str::copy(top_line));
	}
}

macro void @update_target(char &target)
{
	target = target == '.' ? 'x' : '%';
}
macro bool is_empty(char c)
{
	return c == '.' || c == 'x' || c == '%';
}
fn bool round(CharsArray* list, int round)
{
	isz max_x = list.get(0).len - 1;
	isz max_y = list.len() - 1;
	foreach (i, char[] line : list)
	{
		foreach OUTER: (j, &cref : line)
		{
			char c = *cref;
			if (c != '#') continue;
			assert(i > 0 && i < max_y && j > 0 && j < max_x);
			char* n;
			char* s;
			char* w;
			char* e;
			char[] north = list.get(i - 1);
			char[] south = list.get(i + 1);
			bool nw = is_empty(north[j - 1] );
			bool ne = is_empty(north[j + 1]);
			if (ne && nw) n = &list.get(i - 1)[j];
			bool sw = is_empty(south[j - 1] );
			bool se = is_empty(south[j + 1]);
			if (se && sw) s = &list.get(i + 1)[j];
			if (nw && sw) w = &line[j - 1];
			if (ne && se) e = &line[j + 1];
			if (ne && se && sw && nw && (!n || is_empty(*n)) && (!s || is_empty(*s)) && (!e || is_empty(*e)) && (!w || is_empty(*w))) continue OUTER;
			for (int r = 0; r < 4; r++)
			{
				switch ((r + round) % 4)
				{
					case 0:
						if (n && is_empty(*n))
						{
							@update_target(*n);
							*cref = 'n';
							continue OUTER;
						}
					case 1:
						if (s && is_empty(*s))
						{
							@update_target(*s);
							*cref = 's';
							continue OUTER;
						}
					case 2:
						if (w && is_empty(*w))
						{
							@update_target(*w);
							*cref = 'w';
							continue OUTER;
						}
					case 3:
						if (e && is_empty(*e))
						{
							@update_target(*e);
							*cref = 'e';
							continue OUTER;
						}

				}
			}
		}
	}
	bool elves_moved = false;
	foreach (i, char[] line : list)
    {
    	foreach (j, &cref : line)
    	{
    	    char c = *cref;
    	    char *new_ref;
    	    switch (c)
    	    {
    	        case 'n': new_ref = &list.get(i - 1)[j];
    	        case 's': new_ref = &list.get(i + 1)[j];
    	        case 'w': new_ref = &line[j - 1];
    	        case 'e': new_ref = &line[j + 1];
    	        default: continue;
    	    }
    	    if (*new_ref == 'x')
    	    {
    	        *cref = '.';
    	        elves_moved = true;
    	        *new_ref = '#';
    	    }
    	    else
    	    {
    	        *cref = '#';
    	    }
    	}
    }
	foreach (i, char[] line : list)
    {
    	foreach (j, &cref : line)
    	{
    	    switch (*cref)
    	    {
    	        case '.':
    	        case '#':
    	            continue;
    	        default:
    	            *cref = '.';
    	    }
    	}
    }
    return elves_moved;
}

fn void count_empty_tiles(CharsArray list)
{
	isz first_x = 1000;
	isz last_x = 0;
	isz first_y = 1000;
	isz last_y = 0;
	isz elves = 0;
	foreach (i, char[] line : list)
    {
    	foreach (j, c : line)
    	{
    	    if (c == '#')
    	    {
    	        elves++;
    	        if (j < first_x) first_x = j;
    	        if (j > last_x) last_x = j;
    	        if (i < first_y) first_y = i;
    	        if (i > last_y) last_y = i;
    	    }
    	}
    }
    isz area = (last_x - first_x + 1) * (last_y - first_y + 1);
    io::printfln("Empty squares: %d", area - elves);
}

fn void part1()
{
	CharsArray list;
	list.init();
	load_map(&list);
	for (int i = 0; i < 10; i++)
	{
		round(&list, i);
	}
	count_empty_tiles(list);
}

fn void part2()
{
	CharsArray list;
	list.init();
	load_map(&list);
	for (int i = 0;; i++)
	{
		if (!round(&list, i))
		{
			io::printfln("Elves stopped moving round %d", i + 1);
			break;
		}
	}
}

fn void main()
{
	part1();
	part2();
}