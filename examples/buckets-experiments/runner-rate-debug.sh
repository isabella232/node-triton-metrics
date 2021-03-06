#!/bin/bash
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2018, Joyent, Inc.
#

set -o errexit
if [[ -n ${TRACE} ]]; then
    set -o xtrace
fi

infile=$1
jsonfile=$2
debugval=$3

if [[ ! -f $infile || ! -f $jsonfile ]]; then
    echo "Usage: $0 <infile> <jsonfile> [<debugval>]" >&2
    exit 2
fi

json=$(json < $jsonfile)
buckets=$(json -e "this.strbuckets = this.buckets.join(' ')" strbuckets <<<"${json}")
description=$(json description <<<"${json}")
key=$(json key <<<"${json}")
file=$(basename ${infile})

if [[ -z ${buckets} || -z ${description} || -z ${key} ]]; then
    echo "Bad JSON in ${jsonfile}" >&2
    exit 2
fi

DEBUG_PROM_VALUE=${debugval} \
    node ./error-estimator-rate.js ${buckets} < ${infile}

echo "# Description: ${description}"

