package model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class SystemNotification implements Serializable {
    private static final long serialVersionUID = 1L;

    private long notificationId;
    private Integer userId; // Có thể null nếu gửi chung toàn bộ admin/quản lý
    private String title;
    private String message;
    private String type; // 'STOCK_ALERT', 'SHIPMENT_PENDING', 'STOCKTAKE_SUBMITTED', 'SYSTEM'
    private String referenceUrl;
    private boolean isRead;
    private Timestamp createdAt;

    public SystemNotification() {
        this.isRead = false;
    }

    public SystemNotification(long notificationId, Integer userId, String title, String message, String type, String referenceUrl, boolean isRead, Timestamp createdAt) {
        this.notificationId = notificationId;
        this.userId = userId;
        this.title = title;
        this.message = message;
        this.type = type;
        this.referenceUrl = referenceUrl;
        this.isRead = isRead;
        this.createdAt = createdAt;
    }

    public long getNotificationId() {
        return notificationId;
    }

    public void setNotificationId(long notificationId) {
        this.notificationId = notificationId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getReferenceUrl() {
        return referenceUrl;
    }

    public void setReferenceUrl(String referenceUrl) {
        this.referenceUrl = referenceUrl;
    }

    public boolean isRead() {
        return isRead;
    }

    public void setRead(boolean read) {
        isRead = read;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getFormattedTime() {
        if (createdAt != null) {
            return new SimpleDateFormat("HH:mm · dd/MM/yyyy").format(createdAt);
        }
        return "-";
    }
}

