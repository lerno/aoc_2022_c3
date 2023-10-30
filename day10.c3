module day10;
import std::io;

fn int update_signal_strength(int cycle, int x)
{
	if ((cycle + 20) % 40 == 0)
	{
		return x * cycle;
	}
	return 0;
}

fn void draw_crt(bool[40][6]* crt)
{
	foreach (bool[40]* &row : *crt)
	{
		foreach(pixel : *row)
		{
			io::print(pixel ? "#" : " ");
		}
		io::printn();
	}
}

fn void update_crt(bool[40][6]* crt, int cycle, int x)
{
	int col = (cycle - 1) % 40;
	int row = (cycle - 1) / 40;
	if (x - 1 <= col && x + 1 >= col)
	{
		(*crt)[row][col] = true;
	}
}

fn void part2()
{
	File f = file::open("code.txt", "rb")!!;
	defer (void)f.close();
	bool[40][6] crt;
	int cycle = 0;
	int x = 1;
	while (!f.eof())
	{
		@pool()
		{
			String line = io::treadline(&f)!!;
            String[] commands = line.tsplit(" ");
            switch (commands[0])
            {
                case "noop":
                    cycle++;
                    update_crt(&crt, cycle, x);
                case "addx":
                    cycle++;
                    update_crt(&crt, cycle, x);
                    cycle++;
                    update_crt(&crt, cycle, x);
                    x += commands[1].to_int()!!;
                default:
                    unreachable("Invalid input");
            }
		};
	}
	draw_crt(&crt);
}
fn void part1()
{
	File f = file::open("code.txt", "rb")!!;
	defer (void)f.close();
	int cycle = 0;
	int x = 1;
	int signal_strength = 0;
	while (!f.eof())
	{
		@pool()
		{
			String line = io::treadline(&f)!!;
            String[] commands = line.tsplit(" ");
            switch (commands[0])
            {
                case "noop":
                    cycle++;
                    signal_strength += update_signal_strength(cycle, x);
                case "addx":
                    cycle++;
                    signal_strength += update_signal_strength(cycle, x);
                    cycle++;
                    signal_strength += update_signal_strength(cycle, x);
                    x += commands[1].to_int()!!;
                default:
                    unreachable("Invalid input");
            }
            if (cycle > 222) break;
		};
	}
	io::printfn("Signal strength: %d", signal_strength);
}

fn void main()
{
	part1();
	part2();
}