package com.knittingworld.ui.seller;

import android.content.Intent;
import android.os.Bundle;
import android.view.MenuItem;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.google.firebase.auth.FirebaseAuth;
import com.knittingworld.databinding.ActivitySellerDashboardBinding;
import com.knittingworld.ui.auth.LoginActivity;
import com.knittingworld.utils.CurrencyFormatter;

public class SellerDashboardActivity extends AppCompatActivity {

    private ActivitySellerDashboardBinding binding;
    private SellerViewModel viewModel;
    private SellerOrdersAdapter ordersAdapter;
    private SellerProductsAdapter productsAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivitySellerDashboardBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        setSupportActionBar(binding.toolbar);

        if (FirebaseAuth.getInstance().getCurrentUser() == null) {
            startActivity(new Intent(this, LoginActivity.class));
            finish();
            return;
        }

        viewModel = new ViewModelProvider(this).get(SellerViewModel.class);
        setupUI();
        setupNavigation();
        observeData();
    }

    private void setupUI() {
        // Recent Orders RecyclerView
        ordersAdapter = new SellerOrdersAdapter();
        binding.rvRecentOrders.setLayoutManager(new LinearLayoutManager(this));
        binding.rvRecentOrders.setAdapter(ordersAdapter);

        // Add Product FAB
        binding.fabAddProduct.setOnClickListener(v ->
                startActivity(new Intent(this, AddEditProductActivity.class)));

        // Manage Products button
        binding.btnManageProducts.setOnClickListener(v ->
                binding.bottomNav.setSelectedItemId(com.knittingworld.R.id.nav_seller_products));

        // View All Orders button
        binding.btnViewAllOrders.setOnClickListener(v ->
                binding.bottomNav.setSelectedItemId(com.knittingworld.R.id.nav_seller_orders));

        // Refresh Layout
        binding.swipeRefresh.setOnRefreshListener(() -> {
            viewModel.refreshData();
            binding.swipeRefresh.setRefreshing(false);
        });
    }

    private void setupNavigation() {
        binding.bottomNav.setOnItemSelectedListener(item -> {
            int id = item.getItemId();
            hideAllFragments();
            if (id == com.knittingworld.R.id.nav_seller_home) {
                binding.layoutDashboard.setVisibility(View.VISIBLE);
            } else if (id == com.knittingworld.R.id.nav_seller_products) {
                binding.layoutProducts.setVisibility(View.VISIBLE);
            } else if (id == com.knittingworld.R.id.nav_seller_orders) {
                binding.layoutOrders.setVisibility(View.VISIBLE);
            } else if (id == com.knittingworld.R.id.nav_seller_analytics) {
                binding.layoutAnalytics.setVisibility(View.VISIBLE);
            } else if (id == com.knittingworld.R.id.nav_seller_settings) {
                binding.layoutSettings.setVisibility(View.VISIBLE);
            }
            return true;
        });
    }

    private void hideAllFragments() {
        binding.layoutDashboard.setVisibility(View.GONE);
        binding.layoutProducts.setVisibility(View.GONE);
        binding.layoutOrders.setVisibility(View.GONE);
        binding.layoutAnalytics.setVisibility(View.GONE);
        binding.layoutSettings.setVisibility(View.GONE);
    }

    private void observeData() {
        String sellerId = FirebaseAuth.getInstance().getCurrentUser().getUid();

        // Load seller profile
        viewModel.getSellerProfile(sellerId).observe(this, resource -> {
            if (resource.isSuccess() && resource.data != null) {
                binding.tvStoreName.setText(resource.data.getStoreName() != null
                        ? resource.data.getStoreName() : resource.data.getFullName() + "'s Store");
                binding.tvSellerName.setText("Welcome, " + resource.data.getFullName());
                if (resource.data.getStoreBannerUrl() != null) {
                    com.bumptech.glide.Glide.with(this)
                            .load(resource.data.getStoreBannerUrl())
                            .into(binding.ivStoreBanner);
                }
            }
        });

        // Load dashboard stats
        viewModel.getSellerStats(sellerId).observe(this, resource -> {
            if (resource.isSuccess() && resource.data != null) {
                SellerStats stats = resource.data;
                binding.tvTotalRevenue.setText(CurrencyFormatter.format(stats.getTotalRevenue()));
                binding.tvTotalOrders.setText(String.valueOf(stats.getTotalOrders()));
                binding.tvTotalProducts.setText(String.valueOf(stats.getTotalProducts()));
                binding.tvAvgRating.setText(String.format("%.1f", stats.getAvgRating()));
                binding.tvPendingOrders.setText(stats.getPendingOrders() + " pending");
            }
        });

        // Load recent orders
        viewModel.getSellerOrders(sellerId).observe(this, resource -> {
            if (resource.isSuccess() && resource.data != null) {
                // Show only last 5 on dashboard
                int count = Math.min(resource.data.size(), 5);
                ordersAdapter.submitList(resource.data.subList(0, count));
                binding.tvOrderCount.setText(resource.data.size() + " total orders");
            }
        });

        // Load products
        viewModel.getSellerProducts(sellerId).observe(this, resource -> {
            if (resource.isSuccess() && resource.data != null) {
                productsAdapter.submitList(resource.data);
                binding.tvProductCount.setText(resource.data.size() + " products");
            }
        });
    }
}
