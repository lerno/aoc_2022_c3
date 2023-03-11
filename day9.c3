module day9;
import std::io;
import std::math;
const MAP_SIZE = 400;

struct State
{
	bool[MAP_SIZE][MAP_SIZE] map;
	int[<2>] head;
	int[<2>][] tail;
}

fn void process_line(State* state, char dir, int steps)
{
	for (int s = 0; s < steps; s++)
	{
		switch (dir)
		{
			case 'R': state.head[0] += 1;
			case 'L': state.head[0] -= 1;
			case 'D': state.head[1] -= 1;
			case 'U': state.head[1] += 1;
			default: unreachable();
		}
		assert(state.head[0] > -MAP_SIZE / 2 && state.head[1] > -MAP_SIZE / 2 && state.head[0] < MAP_SIZE / 2 && state.head[1] < MAP_SIZE / 2);
		int tail_parts = state.tail.len;
		int[<2>] last_part = state.head;
		for (int i = 0; i < tail_parts; i++)
		{
			int[<2>] tail = state.tail[i];
			int[<2>] diff = last_part - tail;
			int x_diff = math::abs(diff[0]);
			int y_diff = math::abs(diff[1]);
			switch
			{
				case x_diff > 1 && y_diff > 1:
					assert(y_diff == 2 && x_diff == 2);
					tail[0] += diff[0] / 2;
					tail[1] += diff[1] / 2;
				case x_diff > 1:
					assert(y_diff < 2 && x_diff == 2);
					tail[0] += diff[0] / 2;
					tail[1] += diff[1];
				case y_diff > 1:
					assert(x_diff < 2 && y_diff == 2);
					tail[0] += diff[0];
					tail[1] += diff[1] / 2;
				default:
					break;
			}
			state.tail[i] = tail;
			last_part = tail;
			if (i == tail_parts - 1)
			{
				state.map[tail[0] + MAP_SIZE / 2][tail[1] + MAP_SIZE / 2] = true;
			}
		}
	}
}

macro void part(int $part)
{
	State state;
	state.map[MAP_SIZE / 2][MAP_SIZE / 2] = true;
	int[<2>][$part == 1 ? 1 : 9] tail;
	state.tail = &tail;
	File f = file::open("moves.txt", "rb")!!;
	defer (void)f.close();
	while (!f.eof())
	{
		String line = f.tgetline();
		assert(line.len);
		process_line(&state, line[0], str::to_int(line[2..])!!);
	}
	int sum = 0;
	foreach (bool[MAP_SIZE]* &row : state.map)
	{
		foreach (val : *row) if (val) sum++;
	}
	io::printfn("Grids visited by the tail: %d", sum);
}

fn void main()
{
	part(1);
	part(2);
}