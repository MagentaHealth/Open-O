package org.oscarehr.managers;

import java.util.Calendar;
import java.util.HashMap;
import java.util.Map.Entry;

public final class DayWorkSchedule {
	private boolean isHoliday;

	/**
	 * is null if there's no schedule for the given day. 
	 */
	private Integer timeSlotDurationMin;
	
	/**
	 * This hashmap holds the start of the time slot and the time code for that slot, i.e. scheduleTemplateCode
	 */
	private HashMap<Calendar,Character> timeSlots=new HashMap<Calendar,Character>();

	public Integer getTimeSlotDurationMin() {
    	return (timeSlotDurationMin);
    }

	public void setTimeSlotDurationMin(Integer timeSlotDurationMin) {
    	this.timeSlotDurationMin = timeSlotDurationMin;
    }

	public boolean isHoliday() {
    	return (isHoliday);
    }

	public void setHoliday(boolean isHoliday) {
    	this.isHoliday = isHoliday;
    }

	public HashMap<Calendar, Character> getTimeSlots() {
    	return (timeSlots);
    }

	public void setTimeSlots(HashMap<Calendar, Character> timeSlots) {
    	this.timeSlots = timeSlots;
    }
	
	@Override
	public String toString()
	{
		StringBuilder sb=new StringBuilder();
		
		sb.append("isHoliday=");
		sb.append(isHoliday);
		sb.append(", timeSlotDurationMin=");
		sb.append(timeSlotDurationMin);
		sb.append(", timeBlocks=(");
		for (Entry<Calendar, Character> entry : timeSlots.entrySet())
		{
			sb.append('[');
			sb.append(entry.getKey().getTime());
			sb.append('=');
			sb.append(entry.getValue());
			sb.append(']');
		}
		sb.append(")");
		
		return(sb.toString());
	}
}