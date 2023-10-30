module day11;
import std::io;
import std::math;
struct Monkey
{
	long[100] items;
	int item_count;
	bool op_is_mult;
	int other_op;
	int test;
	int on_true;
	int on_false;
	long inspections;
}

// For help
fn void print_monkeys(Monkey[] monkeys)
{
	foreach (i, &m : monkeys)
	{
		io::printfn("%d: %s, inspect %d, new = old %c %d, / by %d -> %d | %d", i, m.items[:m.item_count], m.inspections, m.op_is_mult ? '*' : '+', m.other_op,
			m.test, m.on_true, m.on_false);
	}
}

fn Monkey[] load_monkeys(Monkey[] monkeys)
{
	File f = file::open("monkey.txt", "rb")!!;
	defer (void)f.close();
	int max_monkey = 0;
	while (!f.eof())
	{
		@pool()
		{
			// Very lazy parsing, assuming a lot about the format.
			String line = io::treadline(&f)!!;
			if (line.len == 0) continue;
            String[] commands = line.tsplit(" ");
            int monkey_num = commands[1][..^2].to_int()!!;
            if (monkey_num > max_monkey) max_monkey = monkey_num;
            Monkey* active_monkey = &monkeys[monkey_num];
			line = io::treadline(&f)!!;
			String[] items = line.tsplit(": ")[1].tsplit(", ");
            foreach (String item : items)
            {
				active_monkey.items[active_monkey.item_count++] = item.to_int()!!;
            }
			line = io::treadline(&f)!!;
			String[] op = line.tsplit("= old ")[1].tsplit(" ");
			active_monkey.op_is_mult = op[0][0] == '*';
			active_monkey.other_op = op[1] == "old" ? -1 : op[1].to_int()!!;
			line = io::treadline(&f)!!;
			active_monkey.test = line.tsplit("by ")[1].to_int()!!;
			line = io::treadline(&f)!!;
			active_monkey.on_true = line.tsplit("key ")[1].to_int()!!;
			line = io::treadline(&f)!!;
			active_monkey.on_false = line.tsplit("key ")[1].to_int()!!;
        };
    }
    return monkeys[..max_monkey];
}

fn long monkey_business(Monkey[] monkeys)
{
	long max;
	long next_max;
	foreach (&m : monkeys)
	{
		if (m.inspections > max)
		{
			next_max = max;
			max = m.inspections;
			continue;
		}
		if (m.inspections > next_max)
		{
			next_max = m.inspections;
		}
	}
	return max * next_max;
}

fn void part1()
{
	Monkey[] monkeys = load_monkeys(&&Monkey[10]{});
	for (int round = 0; round < 20; round++)
	{
		foreach (i, &monkey : monkeys)
		{
			for (int item_id = 0; item_id < monkey.item_count; item_id++)
			{
				monkey.inspections++;
				long level = monkey.items[item_id];
				long other_op = monkey.other_op == -1 ? level : monkey.other_op;
				level = monkey.op_is_mult ? level * other_op : level + other_op;
				level /= 3;
				int to_monkey_id = level % monkey.test ? monkey.on_false : monkey.on_true;
				Monkey* to_monkey = &monkeys[to_monkey_id];
				to_monkey.items[to_monkey.item_count++] = level;
			}
			monkey.item_count = 0;
		}
	}
	io::printfn("Monkey business was: %d", monkey_business(monkeys));
}

fn void part2()
{
	Monkey[] monkeys = load_monkeys(&&Monkey[10]{});

	long divisor = 1;
	// We are only interested of values MOD <common divisor>!
	foreach (&monkey : monkeys) divisor *= monkey.test;

	for (int round = 0; round < 10000; round++)
	{
		foreach (i, &monkey : monkeys)
		{
			for (int item_id = 0; item_id < monkey.item_count; item_id++)
			{
				monkey.inspections++;
				long level = monkey.items[item_id];
				long other_op = monkey.other_op == -1 ? level : monkey.other_op;
				level = level % divisor;
                level = monkey.op_is_mult ? level * other_op : level + other_op;
				int to_monkey_id = level % monkey.test ? monkey.on_false : monkey.on_true;
				Monkey* to_monkey = &monkeys[to_monkey_id];
				to_monkey.items[to_monkey.item_count++] = level;
			}
			monkey.item_count = 0;
		}
	}
	io::printfn("Monkey business was: %d", monkey_business(monkeys));
}

fn void main()
{
	part1();
	part2();
}