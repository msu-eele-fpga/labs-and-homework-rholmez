# lab11 - Riley Holmes

## Overview
Lab 11 consists of creating a platform device driver for our led patterns.

## Question
1) the purpose of the platform bus is the connect undiscoverable devices to drivers that can control them.

2) The compatible property of the device driver is to match the device to the right driver.

3) The purpose of the probe function is to load the module correctly, including connecting the device to the driver.

4) The driver knows what memory addresses are associated with the devices because we tell it what the addresses are.

5) We can write to the devices registers using a character device or sysfs attributes.

6) The purpose of our struct led_patterns_dev state container is to get the led patterns's private data from the platform device.