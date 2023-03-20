module day8;
import std::collections::list;
import std::io;

typedef Forest = distinct List<String>;
fn Forest* parse_forest()
{
	File f = file::open("forest.txt", "rb")!!;
	defer (void)f.close();
	Forest* forest = malloc(Forest);
	forest.init(512);
	while (!f.eof())
	{
		String line = f.tgetline();
		assert(line.len);
		forest.append(line);
	}
	return forest;
}

fn int Forest.is_visible(Forest* this, int x, int y)
{
	if (x == 0 || y == 0) return 5;
	isz last_y = this.len() - 1;
	if (y == last_y) return 5;
	isz last_x = this.get(0).len - 1;
	if (x == last_x) return 5;
	String row = this.get(y);
	char height = row[x];
	int directions_seen_from = 0;
	do FROM_WEST: {
		for (isz fx = 0; fx < x; fx++)
        {
            if (row[fx] >= height) break FROM_WEST;
        }
        return 1;
	};
	do FROM_EAST: {
		for (isz fx = last_x; fx > x; fx--)
        {
            if (row[fx] >= height) break FROM_EAST;
        }
        return 2;
	};
	do FROM_NORTH: {
		for (isz fy = 0; fy < y; fy++)
        {
            if (this.get(fy)[x] >= height) break FROM_NORTH;
        }
        return 3;
	};
	do FROM_SOUTH: {
		for (isz fy = last_y; fy > y; fy--)
        {
            if (this.get(fy)[x] >= height) break FROM_SOUTH;
        }
        return 4;
	};
	return 0;
}

fn int Forest.scenic_score(Forest* this, int x, int y)
{
	isz last_y = this.len() - 1;
	isz last_x = this.get(0).len - 1;
	String row = this.get(y);
	char height = row[x];
	int scenic_score;
	int score = 0;
	for (isz fx = x - 1; fx >= 0; fx--)
    {
        score++;
        if (row[fx] >= height) break;
    }
    scenic_score = score;
    score = 0;
	for (isz fx = x + 1; fx <= last_x; fx++)
    {
        score++;
        if (row[fx] >= height) break;
    }
    scenic_score *= score;
    score = 0;
	for (isz fy = y - 1; fy >= 0; fy--)
	{
		score++;
        if (this.get(fy)[x] >= height) break;
	}
    scenic_score *= score;
    score = 0;
	for (isz fy = y + 1; fy <= last_y; fy++)
	{
		score++;
        if (this.get(fy)[x] >= height) break;
	}
	return scenic_score * score;
}

fn int Forest.visible_from_outside(Forest* forest)
{
	int width = forest.get(0).len;
	int height = (int)forest.len();
	int sum;
	for (int y = 0; y < height; y++)
	{
		String line = forest.get(y);
		assert(line.len == width);
		for (int x = 0; x < width; x++)
		{
			int seen = forest.is_visible(x, y);
			if (seen > 0) sum++;
		}
	}
	return sum;
}

fn int Forest.best_scenic_score(Forest* forest)
{
	int width = forest.get(0).len;
	int height = (int)forest.len();
	int best_scenic_score;
	for (int y = 0; y < height; y++)
	{
		for (int x = 0; x < width; x++)
		{
			int score = forest.scenic_score(x, y);
			if (score > best_scenic_score) best_scenic_score = score;
		}
	}
	return best_scenic_score;
}

fn void part1(Forest* forest)
{
	io::printfn("Visible from outside: %d", forest.visible_from_outside());
}

fn void part2(Forest* forest)
{
	io::printfn("Best scenic score: %d", forest.best_scenic_score());
}

fn void main()
{
	Forest* forest = parse_forest();
	part1(forest);
	part2(forest);
}