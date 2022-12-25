module day25;
import std::io;

int[256] values = { ['2'] = 2, ['1'] = 1, ['0'] = 0, ['-'] = -1, ['='] = -2 };

fn char[] snafu_from_long(char[] buffer, long l)
{
	char[100] temp;
	isz idx = 0;
	if (l == 0)
	{
		return "0";
	}
	while (l)
	{
		long val = l % 5;
		l /= 5;
		switch (val)
		{
			case 0:
			case 1:
			case 2:
				temp[idx++] = (char)(val + '0');
			case 3:
				l++;
				temp[idx++] = '=';
			case 4:
				l++;
				temp[idx++] = '-';
			default:
				unreachable();
		}
	}
	isz len = idx;
	for (int i = 0; i < len; i++)
	{
		buffer[len - i - 1] = temp[i];
	}
	buffer[idx] = 0;
	return buffer.ptr[:idx];
}

fn long snafu_to_long(char[] num)
{
	long value = 0;
    foreach (long i, c : num)
    {
        value *= 5;
        value += values[c];
    }
    return value;
}

fn void part1()
{
	File f;
	f.open("snafu.txt", "rb")!!;
	defer catch(f.close());
	long total = 0;
	while (!f.eof())
	{
		@pool()
        {
        	char[] line = f.tgetline();
        	total += snafu_to_long(line);
        };
	}
	char[100] buffer;
	char[] res = snafu_from_long(&buffer, total);
	io::printfln("%s", res);
}

fn void main()
{
	part1();
}