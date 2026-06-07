#include <stddef.h>

char	*ft_strpbrk(const char *s1, const char *s2)
{
	const char	*p;

	while (*s1)
	{
		p = s2;
		while (*p)
		{
			if (*s1 == *p)
				return ((char *)s1);
			p++;
		}
		s1++;
	}
	return (NULL);
}
