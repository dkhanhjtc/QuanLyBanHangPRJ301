package model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class WorkShift implements Serializable {
    private static final long serialVersionUID = 1L;

    private int shiftId;
    private String shiftCode;
    private int staffId;
    private String staffName;
    private Timestamp startTime;
    private Timestamp endTime;
    private double openingCash;
    private double closingCash;
    private double totalSales;
    private String status; // 'OPEN', 'CLOSED'
    private String note;

    public WorkShift() {
        this.status = "OPEN";
    }

    public WorkShift(int shiftId, String shiftCode, int staffId, Timestamp startTime, Timestamp endTime, double openingCash, double closingCash, double totalSales, String status, String note) {
        this.shiftId = shiftId;
        this.shiftCode = shiftCode;
        this.staffId = staffId;
        this.startTime = startTime;
        this.endTime = endTime;
        this.openingCash = openingCash;
        this.closingCash = closingCash;
        this.totalSales = totalSales;
        this.status = status;
        this.note = note;
    }

    public WorkShift(int shiftId, String shiftCode, int staffId, String staffName, Timestamp startTime, Timestamp endTime, double openingCash, double closingCash, double totalSales, String status, String note) {
        this.shiftId = shiftId;
        this.shiftCode = shiftCode;
        this.staffId = staffId;
        this.staffName = staffName;
        this.startTime = startTime;
        this.endTime = endTime;
        this.openingCash = openingCash;
        this.closingCash = closingCash;
        this.totalSales = totalSales;
        this.status = status;
        this.note = note;
    }

    public int getShiftId() {
        return shiftId;
    }

    public void setShiftId(int shiftId) {
        this.shiftId = shiftId;
    }

    public String getShiftCode() {
        return shiftCode;
    }

    public void setShiftCode(String shiftCode) {
        this.shiftCode = shiftCode;
    }

    public int getStaffId() {
        return staffId;
    }

    public void setStaffId(int staffId) {
        this.staffId = staffId;
    }

    public String getStaffName() {
        return staffName;
    }

    public void setStaffName(String staffName) {
        this.staffName = staffName;
    }

    public Timestamp getStartTime() {
        return startTime;
    }

    public void setStartTime(Timestamp startTime) {
        this.startTime = startTime;
    }

    public Timestamp getEndTime() {
        return endTime;
    }

    public void setEndTime(Timestamp endTime) {
        this.endTime = endTime;
    }

    public double getOpeningCash() {
        return openingCash;
    }

    public void setOpeningCash(double openingCash) {
        this.openingCash = openingCash;
    }

    public double getClosingCash() {
        return closingCash;
    }

    public void setClosingCash(double closingCash) {
        this.closingCash = closingCash;
    }

    public double getTotalSales() {
        return totalSales;
    }

    public void setTotalSales(double totalSales) {
        this.totalSales = totalSales;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public String getFormattedStartTime() {
        if (startTime != null) {
            return new SimpleDateFormat("HH:mm · dd/MM/yyyy").format(startTime);
        }
        return "-";
    }

    public String getFormattedEndTime() {
        if (endTime != null) {
            return new SimpleDateFormat("HH:mm · dd/MM/yyyy").format(endTime);
        }
        return "Đang mở";
    }
}

