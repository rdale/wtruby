/***************************************************************************
                          wt::exthandlers.cpp  -  Wt::Ext specific marshallers
                             -------------------
    begin                : 30-08-2008
    copyright            : (C) 2008 by Richard Dale
    email                : richard.j.dale@gmail.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#include <ruby.h>

#include <wtruby.h>
#include <smokeruby.h>
#include <marshall_macros.h>

#include <Wt/Ext/Button>

DEF_LIST_MARSHALLER( WExtButtonVector, std::vector<Wt::Ext::Button*>, Wt::Ext::Button )

TypeHandler WtExt_handlers[] = {
	{ "std::vector<Wt::Ext::Button*>", marshall_WExtButtonVector },
	{ "std::vector<Wt::Ext::Button*>&", marshall_WExtButtonVector },
    { 0, 0 }
};
