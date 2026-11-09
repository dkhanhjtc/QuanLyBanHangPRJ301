package model;

import java.io.Serializable;

public class Product implements Serializable {
    private static final long serialVersionUID = 1L;

    private String id;
    private String sku;
    private String name;
    private String category;
    private double price;
    private double costPrice;
    private int stockQuantity;
    private int minStock;
    private String unit;
    private String spec;
    private String size;
    private String color;
    private String imageUrl;
    private String status;

    public Product() {
    }

    public Product(String id, String name, String category, double price, double costPrice, int stockQuantity, int minStock, String imageUrl, String status) {
        this.id = id;
        this.sku = id;
        this.name = name;
        this.category = category;
        this.price = price;
        this.costPrice = costPrice;
        this.stockQuantity = stockQuantity;
        this.minStock = minStock;
        this.imageUrl = imageUrl;
        this.status = status;
    }

    public Product(String id, String sku, String name, String category, double price, double costPrice, int stockQuantity, int minStock, String unit, String spec, String imageUrl, String status) {
        this.id = id;
        this.sku = sku != null ? sku : id;
        this.name = name;
        this.category = category;
        this.price = price;
        this.costPrice = costPrice;
        this.stockQuantity = stockQuantity;
        this.minStock = minStock;
        this.unit = unit;
        this.spec = spec;
        this.imageUrl = imageUrl;
        this.status = status;
        parseSpec();
    }

    public Product(String id, String sku, String name, String category, double price, double costPrice, int stockQuantity, int minStock, String unit, String spec, String size, String color, String imageUrl, String status) {
        this.id = id;
        this.sku = sku != null ? sku : id;
        this.name = name;
        this.category = category;
        this.price = price;
        this.costPrice = costPrice;
        this.stockQuantity = stockQuantity;
        this.minStock = minStock;
        this.unit = unit;
        this.spec = spec;
        this.size = size;
        this.color = color;
        this.imageUrl = imageUrl;
        this.status = status;
        if ((this.size == null || this.color == null) && spec != null) {
            parseSpec();
        }
    }

    private void parseSpec() {
        if (spec != null && !spec.trim().isEmpty()) {
            String[] parts = spec.split("·|•|-|,");
            for (String p : parts) {
                String trimmed = p.trim();
                if (trimmed.toLowerCase().startsWith("size") || trimmed.matches("(?i)^(S|M|L|XL|XXL|28|29|30|31|32|33|34)$")) {
                    if (this.size == null) this.size = trimmed.replaceFirst("(?i)size\\s*", "").trim();
                } else if (!trimmed.isEmpty()) {
                    if (this.color == null) this.color = trimmed;
                }
            }
        }
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
        if (this.sku == null) {
            this.sku = id;
        }
    }

    public String getSku() {
        return (sku != null && !sku.isEmpty()) ? sku : id;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public double getCostPrice() {
        return costPrice;
    }

    public void setCostPrice(double costPrice) {
        this.costPrice = costPrice;
    }

    public int getStockQuantity() {
        return stockQuantity;
    }

    public void setStockQuantity(int stockQuantity) {
        this.stockQuantity = stockQuantity;
    }

    public int getMinStock() {
        return minStock;
    }

    public void setMinStock(int minStock) {
        this.minStock = minStock;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public String getSpec() {
        if (spec == null && (size != null || color != null)) {
            String s = "";
            if (size != null && !size.isEmpty()) s += "Size " + size;
            if (color != null && !color.isEmpty()) s += (s.isEmpty() ? "" : " · ") + color;
            return s;
        }
        return spec;
    }

    public void setSpec(String spec) {
        this.spec = spec;
        parseSpec();
    }

    public String getSize() {
        return size;
    }

    public void setSize(String size) {
        this.size = size;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    // Alias for JSP EL ${p.image}
    public String getImage() {
        return imageUrl;
    }

    public void setImage(String image) {
        this.imageUrl = image;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isLowStock() {
        return stockQuantity <= minStock;
    }

    @Override
    public String toString() {
        return "Product{" +
                "id='" + id + '\'' +
                ", name='" + name + '\'' +
                ", category='" + category + '\'' +
                ", price=" + price +
                ", stockQuantity=" + stockQuantity +
                ", minStock=" + minStock +
                '}';
    }
}

