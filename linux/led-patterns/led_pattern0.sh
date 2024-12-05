#!/bin/bash
HPS_LED_CONTROL="/sys/devices/platform/ff245a80.led_patterns/hps_led_control"
BASE_PERIOD="/sys/devices/platform/ff245a80.led_patterns/base_period"
LED_REG="/sys/devices/platform/ff245a80.led_patterns/led_reg"

# Enable software-control mode
echo 0 > $HPS_LED_CONTROL

while true
do
    echo 0x55 > $LED_REG
    sleep 0.25
    echo 0xaa > $LED_REG
    sleep 0.25
done