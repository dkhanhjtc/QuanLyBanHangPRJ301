package model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class ActivityLog implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;
    private String userName;
    private String action;
    private String details;
    private String ipAddress;
    private String role;
    private String recordCode;
    private String result;
    private Timestamp createdAt;

    public ActivityLog() {
    }

    public ActivityLog(int id, int userId, String userName, String action, String details, Timestamp createdAt) {
        this.id = id;
        this.userId = userId;
        this.userName = userName;
        this.action = action;
        this.details = details;
        this.createdAt = createdAt;
    }

    public ActivityLog(int id, int userId, String userName, String action, String details, String ipAddress, String role, String recordCode, String result, Timestamp createdAt) {
        this.id = id;
        this.userId = userId;
        this.userName = userName;
        this.action = action;
        this.details = details;
        this.ipAddress = ipAddress;
        this.role = role;
        this.recordCode = recordCode;
        this.result = result;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getDetails() {
        return details;
    }

    public void setDetails(String details) {
        this.details = details;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getRecordCode() {
        return recordCode;
    }

    public void setRecordCode(String recordCode) {
        this.recordCode = recordCode;
    }

    public String getResult() {
        return result;
    }

    public void setResult(String result) {
        this.result = result;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getFormattedTime() {
        if (createdAt == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
        return sdf.format(createdAt);
    }

    public String getFormattedDate() {
        if (createdAt == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        return sdf.format(createdAt);
    }

    @Override
    public String toString() {
        return "ActivityLog{" +
                "id=" + id +
                ", userName='" + userName + '\'' +
                ", action='" + action + '\'' +
                ", recordCode='" + recordCode + '\'' +
                ", result='" + result + '\'' +
                '}';
    }
}

