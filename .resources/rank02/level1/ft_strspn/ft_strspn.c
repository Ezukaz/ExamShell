#include <stddef.h>

size_t	ft_strspn(const char *s, const char *accept)
{
	size_t		count;
	const char	*p;

	count = 0;
	while (*s)
	{
		p = accept;
		while (*p)
		{
			if (*s == *p)
				break ;
			p++;
		}
		if (*p == '\0')
			return (count);
		count++;
		s++;
	}
	return (count);
}
