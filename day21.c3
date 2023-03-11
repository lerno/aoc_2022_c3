module day21;
import std::io;
import std::math;
import std::collections::map;
import std::collections::list;

define MonkeyList = List<Monkey>;
define NameMap = HashMap<String, MonkeyId>;

enum Action
{
	VALUE,
	MULT,
	DIV,
	PLUS,
	MINUS,
}

define MonkeyId = distinct int;

struct Monkey
{
	MonkeyId id;
	String name;
	Action action;
	bool is_human;
	bool had_human;
	union
	{
		Monkey*[2] other_monkey;
		String[2] other_monkey_unresolved;
		long value;
	}
}
fn void load_monkeys(MonkeyList* list, MonkeyId* root_index, MonkeyId *humn_index)
{
	File f = file::open("monkeys.txt", "rb")!!;
	defer (void)f.close();
	NameMap map;
	map.init();
	defer map.free();
	MonkeyId index = 0;
	while (!f.eof())
	{
		@pool()
		{
			String line = f.tgetline();
			String[] parts = line.tsplit(": ");
			String name = parts[0].copy();
			if (name == "root")
			{
				*root_index = index;
			}
			Monkey m = { .name = name, .id = index };
			if (name == "humn")
			{
				*humn_index = index;
				m.is_human = true;
				m.had_human = true;
			}
			if (parts[1][0] < 'a')
			{
				m.value = str::to_long(parts[1])!!;
				m.action = Action.VALUE;
			}
			else
			{
				parts = parts[1].tsplit(" ");
				m.other_monkey_unresolved[0] = parts[0].copy();
				m.other_monkey_unresolved[1] = parts[2].copy();
				switch (parts[1][0])
				{
					case '*': m.action = Action.MULT;
					case '/': m.action = Action.DIV;
					case '-': m.action = Action.MINUS;
					case '+': m.action = Action.PLUS;
					default: unreachable();
				}
			}
			map.set(name, index++);
			list.append(m);
		};
	}
	foreach (&monkey : list)
	{
		if (monkey.action == Action.VALUE) continue;
		MonkeyId monkey1 = map.get(monkey.other_monkey_unresolved[0])!!;
		MonkeyId monkey2 = map.get(monkey.other_monkey_unresolved[1])!!;
		monkey.other_monkey = { list.get_ref((int)monkey1), list.get_ref((int)monkey2) };
	}
}

fn long Monkey.getValue(Monkey* m)
{
	if (m.action == Action.VALUE) return m.value;
	long m1 = m.other_monkey[0].getValue();
	long m2 = m.other_monkey[1].getValue();
	switch (m.action)
	{
		case MULT: return m1 * m2;
		case DIV: return m1 % m2 ? 0x1FFF_FFFF_FFFF_FFFFi64 : m1 / m2;
		case PLUS: return m1 + m2;
		case MINUS: return m1 - m2;
		default: unreachable();
	}
}


fn void part1(Monkey root)
{
	long value = root.getValue();
	io::printfn("Root yells: %d", value);
}

fn bool Monkey.has_human(Monkey* m)
{
	if (m.is_human) return true;
	if (m.action == Action.VALUE) return false;
	bool m1 = m.other_monkey[0].has_human();
	bool m2 = m.other_monkey[1].has_human();
	if (m1 || m2)
	{
		m.had_human = true;
		assert(m1 != m2);
		return true;
	}
	return false;
}

fn bool Monkey.discover_human(Monkey* m, long value)
{
	if (m.is_human)
	{
		io::printfn("Human yells: %d", value);
		return true;
	}
	if (!m.had_human) return false;
	Monkey* m1 = m.other_monkey[0];
	Monkey* m2 = m.other_monkey[1];
	switch (m.action)
	{
		case VALUE:
			return false;
		case PLUS:
			if (m2.had_human) @swap(m1, m2);
			return m1.discover_human(value - m2.getValue());
		case MINUS:
			if (m1.had_human)
			{
				return m1.discover_human(value + m2.getValue());
			}
			return m2.discover_human(m1.getValue() - value);
		case DIV:
			if (m1.had_human)
			{
				return m1.discover_human(value * m2.getValue());
			}
			return m2.discover_human(m1.getValue() / value);
		case MULT:
			if (m2.had_human) @swap(m1, m2);
			return m1.discover_human(value / m2.getValue());
		default:
			unreachable();
	}
}

fn void part2(Monkey* root, Monkey* humn)
{
	Monkey* m1 = root.other_monkey[0];
	Monkey* m2 = root.other_monkey[1];
	Monkey* h = m1.has_human() ? m1 : m2;
	Monkey* o = h == m1 ? m2 : m1;
	bool found = h.discover_human(o.getValue());
	assert(found);
}

fn void main()
{
	MonkeyList list;
	list.init();
	MonkeyId root_index;
	MonkeyId humn_index;
	load_monkeys(&list, &root_index, &humn_index);
	part1(list.get((int)root_index));
	part2(list.get_ref((int)root_index), list.get_ref((int)humn_index));
}