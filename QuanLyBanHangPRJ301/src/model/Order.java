package model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

public class Order implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String code;
    private int createdBy;
    private double totalAmount;
    private String paymentMethod;
    private String status;
    private Timestamp createdAt;

    // View helpers
    private String staffName;
    private List<OrderDetail> details;

    public Order() {
        this.status = "Đã thanh toán";
        this.details = new ArrayList<>();
    }

    public Order(int id, String code, int createdBy, double totalAmount, String paymentMethod, Timestamp createdAt) {
        this.id = id;
        this.code = code;
        this.createdBy = createdBy;
        this.totalAmount = totalAmount;
        this.paymentMethod = paymentMethod;
        this.status = "Đã thanh toán";
        this.createdAt = createdAt;
        this.details = new ArrayList<>();
    }

    public Order(int id, String code, int createdBy, String staffName, double totalAmount, String paymentMethod, String status, Timestamp createdAt) {
        this.id = id;
        this.code = code;
        this.createdBy = createdBy;
        this.staffName = staffName;
        this.totalAmount = totalAmount;
        this.paymentMethod = paymentMethod;
        this.status = status != null ? status : "Đã thanh toán";
        this.createdAt = createdAt;
        this.details = new ArrayList<>();
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

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getStaffName() {
        return staffName;
    }

    public void setStaffName(String staffName) {
        this.staffName = staffName;
    }

    public List<OrderDetail> getDetails() {
        return details;
    }

    public void setDetails(List<OrderDetail> details) {
        this.details = details;
    }

    // Formatted time for dashboard/pos display: "27/10 · 10:24"
    public String getFormattedTime() {
        if (createdAt == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM · HH:mm");
        return sdf.format(createdAt);
    }

    @Override
    public String toString() {
        return "Order{" +
                "id=" + id +
                ", code='" + code + '\'' +
                ", createdBy=" + createdBy +
                ", totalAmount=" + totalAmount +
                ", paymentMethod='" + paymentMethod + '\'' +
                '}';
    }
}

