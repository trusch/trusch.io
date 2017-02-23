#!/bin/bash

mkdir -p aci
rm -rf aci/*
rm -rf build

for s in scripts/*; do
  bash $s;
done

exit 0
