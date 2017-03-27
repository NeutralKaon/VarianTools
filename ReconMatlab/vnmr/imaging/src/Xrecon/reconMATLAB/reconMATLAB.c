/* reconMATLAB.c */
/*---------------------------------------------------------------------------*/
/*                                                                           */
/* reconMATLAB.c: 2D recon                                                   */
/*                                                                           */
/* Xrecon is free software: you can redistribute it and/or modify            */
/* it under the terms of the GNU General Public License as published by      */
/* the Free Software Foundation, either version 3 of the License, or         */
/* (at your option) any later version.                                       */
/*                                                                           */
/* Xrecon is distributed in the hope that it will be useful,                 */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of            */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the              */
/* GNU General Public License for more details.                              */
/*                                                                           */
/* You should have received a copy of the GNU General Public License         */
/* along with Xrecon. If not, see <http://www.gnu.org/licenses/>.            */
/*                                                                           */
/*---------------------------------------------------------------------------*/

#include "../Xrecon.h"

void reconMATLAB(struct data *d)
{
    char command[256] = {0};
    sprintf(command, "XreconMatlab.sh %s", d->file);
    system(command);
}
