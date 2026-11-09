package model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

public class Stocktake implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String code;
    private String title;
    private String assignedTo;
    private String status; // 'PENDING', 'REVIEW', 'OVERDUE', 'COMPLETED'
    private int totalVariance;
    private Timestamp createdAt;

    private List<StocktakeItem> items;

    public Stocktake() {
        this.status = "REVIEW";
        this.items = new ArrayList<>();
    }

    public Stocktake(int id, String code, String title, String assignedTo, String status, int totalVariance, Timestamp createdAt) {
        this.id = id;
        this.code = code;
        this.title = title;
        this.assignedTo = assignedTo;
        this.status = status;
        this.totalVariance = totalVariance;
        this.createdAt = createdAt;
        this.items = new ArrayList<>();
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getAssignedTo() {
        return assignedTo;
    }

    public void setAssignedTo(String assignedTo) {
        this.assignedTo = assignedTo;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getTotalVariance() {
        return totalVariance;
    }

    public void setTotalVariance(int totalVariance) {
        this.totalVariance = totalVariance;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public List<StocktakeItem> getItems() {
        return items;
    }

    public void setItems(List<StocktakeItem> items) {
        this.items = items;
    }

    public String getFormattedDate() {
        if (createdAt == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM · HH:mm");
        return sdf.format(createdAt);
    }

    @Override
    public String toString() {
        return "Stocktake{" +
                "id=" + id +
                ", code='" + code + '\'' +
                ", title='" + title + '\'' +
                ", assignedTo='" + assignedTo + '\'' +
                ", status='" + status + '\'' +
                ", totalVariance=" + totalVariance +
                '}';
    }
}

