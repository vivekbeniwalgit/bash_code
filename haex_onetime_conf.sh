#!/bin/bash

mkdir -p haex/applications haex/staticContent
mkdir -p haex/applications/batch-jobs/default haex/applications/batch-jobs/cp haex/applications/batch-jobs/wellcare haex/applications/batch-jobs/hap
mkdir -p haex/app_logs
mkdir -p haex/staticContent/broker/exchange/cp haex/staticContent/broker/exchange/hap haex/staticContent/broker/exchange/wellcare haex/staticContent/broker/common/min/js haex/staticContent/broker/common/min/theme
mkdir -p haex/staticContent/employee/exchange/cp haex/staticContent/employee/exchange/hap haex/staticContent/employee/exchange/wellcare haex/staticContent/employee/common/min/js haex/staticContent/employee/common/min/theme
mkdir -p haex/staticContent/employer/exchange/cp haex/staticContent/employer/exchange/hap haex/staticContent/employer/exchange/wellcare haex/staticContent/employer/common/min/js haex/staticContent/employer/common/min/theme
mkdir -p haex/staticContent/exchange-admin/common/min/js haex/staticContent/exchange-admin/common/min/images haex/staticContent/exchange-admin/common/min/css haex/staticContent/exchange-admin/common/min/theme haex/staticContent/exchange-admin/exchange
mkdir -p haex/staticContent/individual/exchange/cp haex/staticContent/individual/exchange/hap haex/staticContent/individual/exchange/wellcare haex/staticContent/individual/common/min/js haex/staticContent/individual/common/min/theme
mkdir -p haex/staticContent/de/min/js haex/staticContent/de/min/assets haex/staticContent/de/min/assets/product haex/staticContent/de/min/assets/hap haex/staticContent/de/min/assets/wellcare haex/staticContent/de/min/assets/cp haex/staticContent/de/min/assets/product/theme haex/staticContent/de/min/assets/product/certificate


chown -R tomcat7:tomcat7 haex
chmod -R 2775 haex