/*
 * Utils.h
 * iSoul
 *
 * Created by François LAMBOLEY on 11/19/11.
 * Copyright (c) 2011 Epita. All rights reserved.
 */

#ifndef iSoul_Utils_h
#define iSoul_Utils_h

#ifndef __clang_analyzer__
# define LEAK_RETAIN(arg) ([(arg) retain])
#else
# define LEAK_RETAIN(arg) (arg)
#endif

#endif
